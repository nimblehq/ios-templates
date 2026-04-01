//
//  WeatherRepositorySpec.swift
//

import Testing

@testable import Data
@testable import Domain

private final class MockNetworkAPI: NetworkAPIProtocol, @unchecked Sendable {

    var responses: [MockResult] = []
    private(set) var requestedConfigurations: [RequestConfiguration] = []

    func performRequest<T: Decodable & Sendable>(
        _ configuration: RequestConfiguration,
        for type: T.Type
    ) async throws -> T {
        requestedConfigurations.append(configuration)

        guard responses.isEmpty == false else {
            throw NetworkAPIError.generic
        }

        switch responses.removeFirst() {
        case let .success(value):
            guard let value = value as? T else {
                throw NetworkAPIError.generic
            }
            return value
        case let .failure(error):
            throw error
        }
    }
}

private enum MockResult {

    case success(Any)
    case failure(Error)
}

@Suite("WeatherRepository")
struct WeatherRepositorySpec {

    @Test("maps geocoding and forecast responses into a WeatherReport")
    func mapsResponsesIntoWeatherReport() async throws {
        let networkAPI = MockNetworkAPI()
        let repository = WeatherRepository(weatherNetworkAPI: networkAPI)

        networkAPI.responses = [
            .success(
                LocationSearchResponse(
                    results: [
                        .init(
                            name: "Singapore",
                            country: "Singapore",
                            admin1: nil,
                            latitude: 1.3521,
                            longitude: 103.8198,
                            timezone: "Asia/Singapore"
                        )
                    ]
                )
            ),
            .success(
                WeatherForecastResponse(
                    current: .init(
                        temperature2M: 29.4,
                        apparentTemperature: 33.1,
                        weatherCode: 2,
                        windSpeed10M: 12.4,
                        isDay: 1
                    ),
                    daily: .init(
                        time: [
                            "2026-03-27",
                            "2026-03-28",
                            "2026-03-29"
                        ],
                        weatherCode: [2, 61, 3],
                        temperature2MMax: [31.2, 30.1, 29.7],
                        temperature2MMin: [25.4, 24.8, 24.5]
                    )
                )
            )
        ]

        let report = try await repository.fetchWeather(for: "Singapore")

        #expect(report.location.name == "Singapore")
        #expect(report.location.country == "Singapore")
        #expect(report.currentWeather.weatherCode == 2)
        #expect(report.currentWeather.isDaylight)
        #expect(report.dailyForecasts.count == 3)
        #expect(networkAPI.requestedConfigurations.count == 2)
        #expect(networkAPI.requestedConfigurations.first is LocationSearchRequestConfiguration)
        #expect(networkAPI.requestedConfigurations.last is WeatherForecastRequestConfiguration)
    }

    @Test("throws locationNotFound when geocoding has no results")
    func throwsLocationNotFoundWhenNoGeocodingResults() async {
        let networkAPI = MockNetworkAPI()
        let repository = WeatherRepository(weatherNetworkAPI: networkAPI)
        networkAPI.responses = [
            .success(LocationSearchResponse(results: []))
        ]

        await #expect(throws: WeatherLookupError.locationNotFound) {
            try await repository.fetchWeather(for: "Unknown")
        }
    }

    @Test("maps transport failures to weatherUnavailable")
    func mapsTransportFailureToWeatherUnavailable() async {
        let networkAPI = MockNetworkAPI()
        let repository = WeatherRepository(weatherNetworkAPI: networkAPI)
        networkAPI.responses = [.failure(NetworkAPIError.generic)]

        await #expect(throws: WeatherLookupError.weatherUnavailable) {
            try await repository.fetchWeather(for: "Singapore")
        }
    }

    @Test("preserves cancellation errors from transport layer")
    func preservesCancellationErrors() async {
        let networkAPI = MockNetworkAPI()
        let repository = WeatherRepository(weatherNetworkAPI: networkAPI)
        networkAPI.responses = [.failure(CancellationError())]

        await #expect(throws: CancellationError.self) {
            try await repository.fetchWeather(for: "Singapore")
        }
    }
}
