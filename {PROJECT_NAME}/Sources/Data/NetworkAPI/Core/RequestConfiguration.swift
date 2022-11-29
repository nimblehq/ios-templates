//
//  RequestConfiguration.swift
//

import Foundation
import Moya

enum RequestConfiguration {}

extension RequestConfiguration: TargetType {

    var baseURL: URL { URL(string: "https://base_url")! }

    var path: String { "" }

    var method: Moya.Method { .get }

    var task: Moya.Task { .requestPlain }

    var headers: [String: String]? { nil }
}
