//
//  WeatherForecastRequestParameters.swift
//

import Alamofire
import Foundation

struct WeatherForecastRequestParameters: Equatable {

    let latitude: Double
    let longitude: Double
    let timezone: String
    let forecastDays: Int

    init(
        latitude: Double,
        longitude: Double,
        timezone: String,
        forecastDays: Int = 5
    ) {
        self.latitude = latitude
        self.longitude = longitude
        self.timezone = timezone
        self.forecastDays = forecastDays
    }

    var values: Parameters {
        [
            "latitude": latitude,
            "longitude": longitude,
            "current": "temperature_2m,apparent_temperature,weather_code,wind_speed_10m,is_day",
            "daily": "weather_code,temperature_2m_max,temperature_2m_min",
            "forecast_days": forecastDays,
            "timezone": timezone
        ]
    }
}
