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

        @Test
        func performRequestDecodesPayload() async throws {
            let requestConfiguration = DummyRequestConfiguration()
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

        @Test
        func performRequestThrows() async {
            let requestConfiguration = DummyRequestConfiguration()
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

