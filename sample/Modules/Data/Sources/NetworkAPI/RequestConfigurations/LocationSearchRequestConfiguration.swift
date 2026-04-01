//
//  LocationSearchRequestConfiguration.swift
//

import Alamofire
import Foundation

struct LocationSearchRequestConfiguration: RequestConfiguration {

    let query: String
    let count: Int

    init(query: String, count: Int = 1) {
        self.query = query
        self.count = count
    }

    var baseURL: String { "https://geocoding-api.open-meteo.com" }

    var endpoint: String { "v1/search" }

    var method: HTTPMethod { .get }

    var parameters: Parameters? {
        // The weather screen only needs the best city candidate, so the request
        // defaults to a single result and keeps the payload small.
        [
            "name": query,
            "count": count,
            "language": "en",
            "format": "json"
        ]
    }

    var encoding: ParameterEncoding { URLEncoding.queryString }
}
