//
//  NetworkAPITests.swift
//

import Foundation
import Testing

@testable import Data

@Suite("NetworkAPI", .serialized)
struct NetworkAPITests {

    @Test("performRequest returns decoded value when the network succeeds")
    func performRequestReturnsDecodedValue() async throws {
        let requestConfiguration = DummyRequestConfiguration()
        NetworkStubber.addStub(requestConfiguration)
        defer { NetworkStubber.removeAllStubs() }

        let networkAPI = NetworkAPI()

        let response = try await networkAPI.performRequest(
            requestConfiguration,
            for: DummyNetworkModel.self
        )

        #expect(response.message == "Hello")
    }

    @Test("performRequest throws when the network returns an error status")
    func performRequestThrowsOnErrorStatus() async throws {
        let requestConfiguration = DummyRequestConfiguration()
        NetworkStubber.addStub(requestConfiguration, data: Foundation.Data(), statusCode: 400)
        defer { NetworkStubber.removeAllStubs() }

        let networkAPI = NetworkAPI()

        await #expect(throws: (any Error).self) {
            try await networkAPI.performRequest(
                requestConfiguration,
                for: DummyNetworkModel.self
            )
        }
    }

    @Test("performAuthenticatedRequest matches performRequest when no interceptor is configured")
    func performAuthenticatedRequestMatchesPerformRequestWithoutInterceptor() async throws {
        let requestConfiguration = DummyRequestConfiguration()
        NetworkStubber.addStub(requestConfiguration)
        defer { NetworkStubber.removeAllStubs() }

        let networkAPI = NetworkAPI(authenticationInterceptor: nil)

        let authenticated = try await networkAPI.performAuthenticatedRequest(
            requestConfiguration,
            for: DummyNetworkModel.self
        )
        let unauthenticated = try await networkAPI.performRequest(
            requestConfiguration,
            for: DummyNetworkModel.self
        )

        #expect(authenticated.message == unauthenticated.message)
    }
}
