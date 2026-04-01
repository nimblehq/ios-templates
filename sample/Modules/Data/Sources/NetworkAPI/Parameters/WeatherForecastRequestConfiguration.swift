//
//  WeatherForecastRequestConfiguration.swift
//

import Alamofire
import Foundation

enum WeatherForecastRequestConfiguration: RequestConfiguration, Equatable {

    case forecast(WeatherForecastRequestParameters)

    var baseURL: String { "https://api.open-meteo.com" }

    var endpoint: String { "v1/forecast" }

    var method: HTTPMethod { .get }

    var parameters: Parameters? {
        // Request only the fields rendered by the sample UI to keep the API
        // contract focused on current conditions and the five-day outlook.
        switch self {
        case let .forecast(parameters):
            parameters.values
        }
    }

    var encoding: ParameterEncoding { URLEncoding.queryString }
}
