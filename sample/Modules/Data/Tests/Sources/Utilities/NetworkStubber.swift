//
//  NetworkStubber.swift
//

import Foundation
import OHHTTPStubs
import OHHTTPStubsSwift

protocol RequestConfigurationStubable {

    var sampleData: Foundation.Data { get }
    var path: String { get }
}

enum NetworkStubber {

    static func removeAllStubs() {
        HTTPStubs.removeAllStubs()
    }

    static func addStub(
        _ request: RequestConfigurationStubable,
        data: Foundation.Data? = nil,
        statusCode: Int32 = 200
    ) {
        OHHTTPStubsSwift.stub(condition: isPath(request.path)) { _ in
            HTTPStubsResponse(
                data: data ?? request.sampleData,
                statusCode: statusCode,
                headers: nil
            )
        }
    }
}
