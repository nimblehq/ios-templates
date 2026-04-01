//
//  DummyRequestConfiguration.swift
//

import Alamofire
import Foundation

@testable import Data

enum DummyRequestConfiguration: RequestConfiguration, Equatable {

    case dummy
    case withParameters(DummyRequestParameters)

    var baseURL: String { "https://example.com" }

    var endpoint: String { "" }

    var method: Alamofire.HTTPMethod { .get }

    var parameters: Parameters? {
        switch self {
        case .dummy:
            nil
        case let .withParameters(parameters):
            parameters.values
        }
    }

    var encoding: Alamofire.ParameterEncoding { URLEncoding.queryString }
}

extension DummyRequestConfiguration: RequestConfigurationStubable {

    var sampleData: Data {
        DummyNetworkModel.json.data(using: .utf8) ?? Data()
    }

    var path: String {
        (try? url.asURL().path) ?? ""
    }
}
