import Domain
import Foundation

enum L10n {

    private final class BundleToken {}

    private static let bundle = Bundle(for: BundleToken.self)

    static var weatherDefaultCityQuery: String {
        text("weather.default_city_query")
    }

    static var weatherScreenTitle: String {
        text("weather.screen.title")
    }

    static var weatherSearchTitle: String {
        text("weather.search.title")
    }

    static var weatherSearchPlaceholder: String {
        text("weather.search.placeholder")
    }

    static var weatherSearchAction: String {
        text("weather.search.action")
    }

    static var weatherSearchCaption: String {
        text("weather.search.caption")
    }

    static var weatherLoadingState: String {
        text("weather.loading")
    }

    static var weatherEmptyStateTitle: String {
        text("weather.empty.title")
    }

    static var weatherEmptyStateMessage: String {
        text("weather.empty.message")
    }

    static var weatherForecastTitle: String {
        text("weather.forecast.title")
    }

    static var weatherStatusTitle: String {
        text("weather.status.title")
    }

    static var weatherMetricToday: String {
        text("weather.metric.today")
    }

    static var weatherMetricWind: String {
        text("weather.metric.wind")
    }

    static var weatherHighLowUnavailable: String {
        text("weather.summary.high_low.unavailable")
    }

    static func weatherApparentTemperature(_ temperature: String) -> String {
        format("weather.summary.feels_like", temperature)
    }

    static func weatherWindSpeed(_ speed: String) -> String {
        format("weather.summary.wind_speed", speed)
    }

    static func weatherHighLow(high: String, low: String) -> String {
        format("weather.summary.high_low", high, low)
    }

    // Open-Meteo exposes many granular weather codes. The sample intentionally
    // groups them into a smaller set of localized labels so text and icon
    // presentation stay simple and consistent.
    static func weatherConditionTitle(for code: Int) -> String {
        switch code {
        case 0:
            text("weather.condition.clear")
        case 1:
            text("weather.condition.mainly_clear")
        case 2:
            text("weather.condition.partly_cloudy")
        case 3:
            text("weather.condition.overcast")
        case 45, 48:
            text("weather.condition.foggy")
        case 51, 53, 55, 56, 57:
            text("weather.condition.drizzle")
        case 61, 63, 65, 66, 67, 80, 81, 82:
            text("weather.condition.rain")
        case 71, 73, 75, 77, 85, 86:
            text("weather.condition.snow")
        case 95, 96, 99:
            text("weather.condition.thunderstorm")
        default:
            text("weather.condition.cloudy")
        }
    }

    static func weatherErrorMessage(for error: WeatherLookupError) -> String {
        switch error {
        case .emptyQuery:
            text("weather.error.empty_query")
        case .locationNotFound:
            text("weather.error.location_not_found")
        case .weatherUnavailable:
            text("weather.error.weather_unavailable")
        }
    }

    private static func text(_ key: String) -> String {
        NSLocalizedString(key, bundle: bundle, comment: "")
    }

    private static func format(_ key: String, _ arguments: CVarArg...) -> String {
        String(format: text(key), locale: .autoupdatingCurrent, arguments: arguments)
    }
}
