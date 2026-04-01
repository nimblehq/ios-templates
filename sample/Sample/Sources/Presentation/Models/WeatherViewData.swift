//
//  WeatherViewData.swift
//

import Domain
import Foundation

private enum WeatherConditionPresentation {

    // Keeps the icon and text mapping in the same presentation layer so the
    // weather summary and forecast rows describe each weather code consistently.
    static func title(for code: Int) -> String {
        L10n.weatherConditionTitle(for: code)
    }

    // Maps Open-Meteo weather codes to the SF Symbol used by the UI.
    // `isDaylight` only affects conditions that have distinct day/night variants,
    // such as clear or partly cloudy skies. Broader categories like rain, snow,
    // fog, or storms intentionally reuse a single symbol because the app only
    // needs a simple at-a-glance visual grouping.
    static func symbolName(for code: Int, isDaylight: Bool) -> String {
        switch code {
        case 0, 1:
            isDaylight ? "sun.max.fill" : "moon.stars.fill"
        case 2:
            isDaylight ? "cloud.sun.fill" : "cloud.moon.fill"
        case 3:
            "cloud.fill"
        case 45, 48:
            "cloud.fog.fill"
        case 51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82:
            "cloud.rain.fill"
        case 71, 73, 75, 77, 85, 86:
            "cloud.snow.fill"
        case 95, 96, 99:
            "cloud.bolt.rain.fill"
        default:
            "cloud.fill"
        }
    }
}

public struct DailyForecastRowViewData: Identifiable, Equatable, Sendable {

    public let dayTitle: String
    public let conditionTitle: String
    public let symbolName: String
    public let temperatureRange: String
    public let date: Date

    public var id: Date { date }
}

public struct WeatherViewData: Equatable, Sendable {

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.setLocalizedDateFormatFromTemplate("EEE")
        return formatter
    }()

    public let locationName: String
    public let locationSubtitle: String
    public let currentTemperature: String
    public let apparentTemperature: String
    public let conditionTitle: String
    public let conditionSymbolName: String
    public let highLow: String
    public let windSpeed: String
    public let dailyForecasts: [DailyForecastRowViewData]

    // Converts domain entities into plain strings the SwiftUI layer can render
    // directly without redoing formatting logic inside views.
    init(report: WeatherReport) {
        let todayForecast = report.dailyForecasts.first

        locationName = report.location.name
        locationSubtitle = Self.locationSubtitle(for: report.location)
        currentTemperature = Self.temperatureText(report.currentWeather.temperatureCelsius)
        apparentTemperature = L10n.weatherApparentTemperature(
            Self.temperatureText(report.currentWeather.apparentTemperatureCelsius)
        )
        conditionTitle = WeatherConditionPresentation.title(for: report.currentWeather.weatherCode)
        conditionSymbolName = WeatherConditionPresentation.symbolName(
            for: report.currentWeather.weatherCode,
            isDaylight: report.currentWeather.isDaylight
        )
        windSpeed = L10n.weatherWindSpeed(
            "\(Int(report.currentWeather.windSpeedKilometersPerHour.rounded()))"
        )
        highLow = todayForecast.map {
            L10n.weatherHighLow(
                high: Self.temperatureText($0.maximumTemperatureCelsius),
                low: Self.temperatureText($0.minimumTemperatureCelsius)
            )
        } ?? L10n.weatherHighLowUnavailable
        dailyForecasts = report.dailyForecasts.map { forecast in
            DailyForecastRowViewData(
                dayTitle: Self.dayFormatter.string(from: forecast.date),
                conditionTitle: WeatherConditionPresentation.title(for: forecast.weatherCode),
                symbolName: WeatherConditionPresentation.symbolName(
                    for: forecast.weatherCode,
                    isDaylight: true
                ),
                temperatureRange: [
                    Self.temperatureText(forecast.minimumTemperatureCelsius),
                    Self.temperatureText(forecast.maximumTemperatureCelsius)
                ].joined(separator: " - "),
                date: forecast.date
            )
        }
    }

    // Region is optional in the geocoding response, so we only include
    // non-empty components when building the secondary location label.
    private static func locationSubtitle(for location: WeatherLocation) -> String {
        [location.region, location.country]
            .compactMap { $0 }
            .joined(separator: ", ")
    }

    // Rounds API values to the whole-number style used throughout the sample UI.
    private static func temperatureText(_ value: Double) -> String {
        "\(Int(value.rounded()))°"
    }
}
