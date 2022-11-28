//
//  RequestConfiguration.swift
//

import Foundation
import Moya

enum RequestConfiguration {

    /// Add cases for each endpoint
}

extension RequestConfiguration: TargetType {

    /// Return base URL for a target
    var baseURL: URL { URL(string: "https://base_url")! }

    /// Return endpoint path for each endpoint case
    var path: String { "" }

    /// Return HTTP method for each endpoint case
    var method: Moya.Method { .get }

    /// Build and Return HTTP task for each endpoint case
    var task: Moya.Task { .requestPlain }

    /// Return the appropriate HTTP headers for every endpoint case
    var headers: [String: String]? { ["Content-Type": "application/json"] }

    /// Return stub/mock data for use in testing. Default is `Data()`
    var sampleData: Data { Data() }

    /// Return the type of validation to perform on the request. Default is `.none`.
    var validationType: ValidationType { .successCodes }
}
