//
//  WeatherRepository.swift
//

import Domain
import Foundation

public struct WeatherRepository: WeatherRepositoryProtocol {

    private let weatherNetworkAPI: any NetworkAPIProtocol

    public init() {
        self.init(weatherNetworkAPI: NetworkAPI())
    }

    init(weatherNetworkAPI: any NetworkAPIProtocol) {
        self.weatherNetworkAPI = weatherNetworkAPI
    }

    // The forecast endpoint returns dates as yyyy-MM-dd strings, so we parse
    // them with a fixed locale/timezone to avoid device-specific drift.
    private static func weatherDate(from value: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: value)
    }

    // Open-Meteo uses a two-step flow: resolve the city first, then request the
    // forecast using the coordinates from the best geocoding result.
    public func fetchWeather(for query: String) async throws -> WeatherReport {
        do {
            let locationResponse = try await weatherNetworkAPI.performRequest(
                LocationSearchRequestConfiguration(query: query),
                for: LocationSearchResponse.self
            )

            guard let location = locationResponse.results?.first else {
                throw WeatherLookupError.locationNotFound
            }

            let forecastResponse = try await weatherNetworkAPI.performRequest(
                WeatherForecastRequestConfiguration.forecast(
                    WeatherForecastRequestParameters(
                        latitude: location.latitude,
                        longitude: location.longitude,
                        timezone: location.timezone ?? "auto"
                    )
                ),
                for: WeatherForecastResponse.self
            )

            return try makeWeatherReport(location: location, forecast: forecastResponse)
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as WeatherLookupError {
            throw error
        } catch {
            throw WeatherLookupError.weatherUnavailable
        }
    }

    private func makeWeatherReport(
        location: LocationSearchResponse.Result,
        forecast: WeatherForecastResponse
    ) throws -> WeatherReport {
        // Convert the raw API payloads into the domain model the app uses.
        let location = WeatherLocation(
            name: location.name,
            region: location.admin1?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
            country: location.country,
            latitude: location.latitude,
            longitude: location.longitude
        )

        let currentWeather = CurrentWeather(
            temperatureCelsius: forecast.current.temperature2M,
            apparentTemperatureCelsius: forecast.current.apparentTemperature,
            windSpeedKilometersPerHour: forecast.current.windSpeed10M,
            weatherCode: forecast.current.weatherCode,
            isDaylight: forecast.current.isDay == 1
        )

        // The daily payload is column-based. We only read up to the shortest
        // array so partially missing fields do not cause index mismatches.
        let forecastCount = min(
            forecast.daily.time.count,
            forecast.daily.weatherCode.count,
            forecast.daily.temperature2MMax.count,
            forecast.daily.temperature2MMin.count
        )

        let dailyForecasts = try (0..<forecastCount).map { index in
            guard let date = Self.weatherDate(from: forecast.daily.time[index]) else {
                throw WeatherLookupError.weatherUnavailable
            }

            return DailyForecast(
                date: date,
                minimumTemperatureCelsius: forecast.daily.temperature2MMin[index],
                maximumTemperatureCelsius: forecast.daily.temperature2MMax[index],
                weatherCode: forecast.daily.weatherCode[index]
            )
        }

        // The screen expects at least one forecast row; treat an empty payload
        // as unavailable weather data rather than showing a broken summary.
        guard dailyForecasts.isEmpty == false else {
            throw WeatherLookupError.weatherUnavailable
        }

        return WeatherReport(
            location: location,
            currentWeather: currentWeather,
            dailyForecasts: dailyForecasts
        )
    }
}
