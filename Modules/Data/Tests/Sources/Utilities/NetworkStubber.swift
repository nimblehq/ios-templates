//
//  NetworkStubber.swift
//

import OHHTTPStubs

protocol RequestConfigurationStubable {

    var sampleData: Data { get }
    var path: String { get }
}

enum NetworkStubber {

    static func removeAllStubs() {
        HTTPStubs.removeAllStubs()
    }

    static func stub(
        _ request: RequestConfigurationStubable,
        data: Data? = nil,
        statusCode: Int32 = 200
    ) {
        OHHTTPStubs.stub(condition: isPath(request.path)) { _ in
            HTTPStubsResponse(
                data: data ?? request.sampleData,
                statusCode: statusCode,
                headers: nil
            )
        }
    }
}
