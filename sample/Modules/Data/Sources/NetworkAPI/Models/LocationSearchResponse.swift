//
//  LocationSearchResponse.swift
//

import Foundation

struct LocationSearchResponse: Decodable, Sendable {

    let results: [Result]?

    struct Result: Decodable, Sendable {

        let name: String
        let country: String
        let admin1: String?
        let latitude: Double
        let longitude: Double
        let timezone: String?
    }
}
