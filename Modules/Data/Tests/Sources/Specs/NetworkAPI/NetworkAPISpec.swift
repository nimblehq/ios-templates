//
//  NetworkAPISpec.swift
//

import Nimble
import Quick

@testable import Data

final class NetworkAPISpec: AsyncSpec {

    override class func spec() {

        // swiftlint:disable closure_body_length
        describe("a NetworkAPI") {

            var networkAPI: NetworkAPI!
            var requestConfiguration: DummyRequestConfiguration!

            describe("its performRequest") {

                beforeEach {
                    requestConfiguration = DummyRequestConfiguration()
                }

                afterEach {
                    NetworkStubber.removeAllStubs()
                }

                context("when network returns value") {

                    beforeEach {
                        NetworkStubber.stub(requestConfiguration)
                        networkAPI = NetworkAPI()
                    }

                    it("returns message as Hello") {
                        let response = try await networkAPI.performRequest(
                            requestConfiguration,
                            for: DummyNetworkModel.self
                        )
                        expect(response.message) == "Hello"
                    }
                }

                context("when network returns error") {

                    beforeEach {
                        NetworkStubber.stub(requestConfiguration, data: Data(), statusCode: 400)
                        networkAPI = NetworkAPI()
                    }

                    it("throws error") {
                        await expect {
                            try await networkAPI.performRequest(
                                requestConfiguration,
                                for: DummyNetworkModel.self
                            )
                        }.to(throwError())
                    }
                }
            }
        }
        // swiftlint:enable closure_body_length
    }
}
