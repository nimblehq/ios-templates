import Foundation
import Nimble
import Quick

final class ApplicationSpec: QuickSpec {

    override func spec() {

        var app: XCUIApplication!

        describe("a {PROJECT_NAME} app") {

            beforeEach {
                app = XCUIApplication()
                app.launch()
            }

            afterEach {
                app.terminate()
            }

            context("when opens") {

                it("empty tests") {
                    expect(true) == true
                }
            }
        }
    }
}
