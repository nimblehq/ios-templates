// TODO: Remove this file

import Nimble
import Quick

@testable import Domain

final class DummySpec: QuickSpec {

    override class func spec() {

        describe("A Dummy") {

            context("given a dummy message") {
                let message = "Hello"

                it("equals Hello") {
                    expect(message) == "Hello"
                }
            }
        }
    }
}
