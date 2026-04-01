//
//  WeatherViewModelSpec.swift
//

import Foundation
import Testing

@testable import Domain
@testable import Sample

private actor StubFetchWeatherUseCase: FetchWeatherUseCaseProtocol {

    private var queuedResults: [Result<WeatherReport, Error>] = []
    private(set) var receivedQueries: [String] = []

    func enqueue(_ result: Result<WeatherReport, Error>) {
        queuedResults.append(result)
    }

    func execute(for query: String) async throws -> WeatherReport {
        receivedQueries.append(query)

        guard queuedResults.isEmpty == false else {
            return makeWeatherReport()
        }

        return try queuedResults.removeFirst().get()
    }
}

private func makeWeatherReport() -> WeatherReport {
    WeatherReport(
        location: WeatherLocation(
            name: "Singapore",
            region: nil,
            country: "Singapore",
            latitude: 1.3521,
            longitude: 103.8198
        ),
        currentWeather: CurrentWeather(
            temperatureCelsius: 29,
            apparentTemperatureCelsius: 33,
            windSpeedKilometersPerHour: 12,
            weatherCode: 2,
            isDaylight: true
        ),
        dailyForecasts: [
            DailyForecast(
                date: Date(timeIntervalSince1970: 1_743_033_600),
                minimumTemperatureCelsius: 25,
                maximumTemperatureCelsius: 31,
                weatherCode: 2
            )
        ]
    )
}

private func makeViewModel(
    fetchWeatherUseCase: any FetchWeatherUseCaseProtocol
) async -> WeatherViewModel {
    await MainActor.run {
        WeatherViewModel(
            defaultQuery: "Singapore",
            fetchWeatherUseCase: fetchWeatherUseCase
        )
    }
}

@Suite("WeatherViewModel")
struct WeatherViewModelSpec {

    @Test("loads weather for the default city")
    func loadsWeatherForDefaultCity() async {
        let useCase = StubFetchWeatherUseCase()
        await useCase.enqueue(.success(makeWeatherReport()))
        let viewModel = await makeViewModel(fetchWeatherUseCase: useCase)
        await viewModel.load()

        let receivedQueries = await useCase.receivedQueries
        let locationName = await viewModel.weather?.locationName
        let errorMessage = await viewModel.errorMessage
        let isLoading = await viewModel.isLoading

        #expect(receivedQueries == ["Singapore"])
        #expect(locationName == "Singapore")
        #expect(errorMessage == nil)
        #expect(isLoading == false)
    }

    @Test("keeps the last successful weather when a refresh fails")
    func keepsLastSuccessfulWeatherWhenRefreshFails() async {
        let useCase = StubFetchWeatherUseCase()
        await useCase.enqueue(.success(makeWeatherReport()))
        let viewModel = await makeViewModel(fetchWeatherUseCase: useCase)

        await viewModel.load()
        await useCase.enqueue(.failure(WeatherLookupError.weatherUnavailable))
        await viewModel.refresh()

        let locationName = await viewModel.weather?.locationName
        let errorMessage = await viewModel.errorMessage

        #expect(locationName == "Singapore")
        #expect(errorMessage == L10n.weatherErrorMessage(for: .weatherUnavailable))
    }

    @Test("ignores cancellation when a refresh is interrupted")
    func ignoresCancellationDuringRefresh() async {
        let useCase = StubFetchWeatherUseCase()
        await useCase.enqueue(.success(makeWeatherReport()))
        let viewModel = await makeViewModel(fetchWeatherUseCase: useCase)

        await viewModel.load()
        await useCase.enqueue(.failure(CancellationError()))
        await viewModel.refresh()

        let locationName = await viewModel.weather?.locationName
        let errorMessage = await viewModel.errorMessage

        #expect(locationName == "Singapore")
        #expect(errorMessage == nil)
    }

    @Test("refreshes using the visible query after a failed search")
    func refreshesVisibleQueryAfterFailedSearch() async {
        let useCase = StubFetchWeatherUseCase()
        await useCase.enqueue(.success(makeWeatherReport()))
        let viewModel = await makeViewModel(fetchWeatherUseCase: useCase)

        await viewModel.load()
        await MainActor.run {
            viewModel.searchText = "Tokyo"
        }
        await useCase.enqueue(.failure(WeatherLookupError.weatherUnavailable))
        await viewModel.search()
        await useCase.enqueue(.success(makeWeatherReport()))
        await viewModel.refresh()

        let receivedQueries = await useCase.receivedQueries
        #expect(receivedQueries == ["Singapore", "Tokyo", "Tokyo"])
    }
}
