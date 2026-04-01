//
//  DummyRequestParameters.swift
//

import Alamofire

struct DummyRequestParameters: Equatable {

    let message: String

    var values: Parameters {
        ["message": message]
    }
}
