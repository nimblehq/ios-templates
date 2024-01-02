//
//  DummyRequestConfiguration.swift
//

import Alamofire

@testable import Data

struct DummyRequestConfiguration: RequestConfiguration {

    var baseURL: String { "https://example.com" }

    var endpoint: String { "" }

    var method: Alamofire.HTTPMethod { .get }

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
