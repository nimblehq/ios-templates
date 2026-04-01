//
//  WeatherForecastResponse.swift
//

import Foundation

struct WeatherForecastResponse: Decodable, Sendable {

    let current: Current
    let daily: Daily

    struct Current: Decodable, Sendable {

        let temperature2M: Double
        let apparentTemperature: Double
        let weatherCode: Int
        let windSpeed10M: Double
        let isDay: Int

        enum CodingKeys: String, CodingKey {

            case temperature2M = "temperature_2m"
            case apparentTemperature = "apparent_temperature"
            case weatherCode = "weather_code"
            case windSpeed10M = "wind_speed_10m"
            case isDay = "is_day"
        }
    }

    struct Daily: Decodable, Sendable {

        let time: [String]
        let weatherCode: [Int]
        let temperature2MMax: [Double]
        let temperature2MMin: [Double]

        enum CodingKeys: String, CodingKey {

            case time
            case weatherCode = "weather_code"
            case temperature2MMax = "temperature_2m_max"
            case temperature2MMin = "temperature_2m_min"
        }
    }
}
