import Foundation
import Testing

@testable import Data

@Suite("NetworkAPI")
struct NetworkAPITests {

    @Test("returns the decoded response when the request succeeds")
    func returnsDecodedResponseWhenTheRequestSucceeds() async throws {
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

    @Test("throws an error when the request fails")
    func throwsAnErrorWhenTheRequestFails() async {
        let requestConfiguration = DummyRequestConfiguration()
        NetworkStubber.addStub(requestConfiguration, data: Data(), statusCode: 400)
        defer { NetworkStubber.removeAllStubs() }

        let networkAPI = NetworkAPI()

        do {
            let _: DummyNetworkModel = try await networkAPI.performRequest(
                requestConfiguration,
                for: DummyNetworkModel.self
            )
            Issue.record("Expected performRequest to throw an error.")
        } catch {}
    }
}
