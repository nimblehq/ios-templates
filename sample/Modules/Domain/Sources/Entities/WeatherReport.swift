//
//  WeatherReport.swift
//

import Foundation

public struct WeatherReport: Equatable, Sendable {

    public let location: WeatherLocation
    public let currentWeather: CurrentWeather
    public let dailyForecasts: [DailyForecast]

    public init(
        location: WeatherLocation,
        currentWeather: CurrentWeather,
        dailyForecasts: [DailyForecast]
    ) {
        self.location = location
        self.currentWeather = currentWeather
        self.dailyForecasts = dailyForecasts
    }
}

public struct WeatherLocation: Equatable, Sendable {

    public let name: String
    public let region: String?
    public let country: String
    public let latitude: Double
    public let longitude: Double

    public init(
        name: String,
        region: String?,
        country: String,
        latitude: Double,
        longitude: Double
    ) {
        self.name = name
        self.region = region
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
    }
}

public struct CurrentWeather: Equatable, Sendable {

    public let temperatureCelsius: Double
    public let apparentTemperatureCelsius: Double
    public let windSpeedKilometersPerHour: Double
    public let weatherCode: Int
    public let isDaylight: Bool

    public init(
        temperatureCelsius: Double,
        apparentTemperatureCelsius: Double,
        windSpeedKilometersPerHour: Double,
        weatherCode: Int,
        isDaylight: Bool
    ) {
        self.temperatureCelsius = temperatureCelsius
        self.apparentTemperatureCelsius = apparentTemperatureCelsius
        self.windSpeedKilometersPerHour = windSpeedKilometersPerHour
        self.weatherCode = weatherCode
        self.isDaylight = isDaylight
    }
}

public struct DailyForecast: Identifiable, Equatable, Sendable {

    public var id: Date { date }

    public let date: Date
    public let minimumTemperatureCelsius: Double
    public let maximumTemperatureCelsius: Double
    public let weatherCode: Int

    public init(
        date: Date,
        minimumTemperatureCelsius: Double,
        maximumTemperatureCelsius: Double,
        weatherCode: Int
    ) {
        self.date = date
        self.minimumTemperatureCelsius = minimumTemperatureCelsius
        self.maximumTemperatureCelsius = maximumTemperatureCelsius
        self.weatherCode = weatherCode
    }
}

public enum WeatherLookupError: Error, Equatable {

    case emptyQuery
    case locationNotFound
    case weatherUnavailable
}
