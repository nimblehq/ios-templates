//
//  NetworkAPISwiftTestingTests.swift
//

import Foundation
import Testing

@testable import Data

@Suite("NetworkAPI")
enum NetworkAPISwiftTestingTests {

    @Suite("when the stub returns 200 with a JSON body")
    struct WhenStubReturnsSuccess {

        @Test(.tags(.networkIntegration))
        func performRequestDecodesPayload() async throws {
            let requestConfiguration = DummyRequestConfiguration.dummy
            let networkAPI = NetworkAPI()

            NetworkStubber.stub(requestConfiguration)
            defer { NetworkStubber.removeAllStubs() }

            let response = try await networkAPI.performRequest(
                requestConfiguration,
                for: DummyNetworkModel.self
            )

            #expect(response.message == "Hello")
        }
    }

    @Suite("when the stub returns a client error status")
    struct WhenStubReturnsClientError {

        @Test(.tags(.networkIntegration))
        func performRequestThrows() async {
            let requestConfiguration = DummyRequestConfiguration.dummy
            let networkAPI = NetworkAPI()

            NetworkStubber.stub(requestConfiguration, data: Foundation.Data(), statusCode: 400)
            defer { NetworkStubber.removeAllStubs() }

            await #expect(throws: Error.self) {
                try await networkAPI.performRequest(
                    requestConfiguration,
                    for: DummyNetworkModel.self
                )
            }
        }
    }
}

extension Tag {
    @Tag static var networkIntegration: Tag
}
