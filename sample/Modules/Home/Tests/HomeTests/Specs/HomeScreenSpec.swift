import Home
import HomeTesting
import Nimble
import Quick

final class HomeScreenSpec: QuickSpec {

    override class func spec() {
        describe("HomeScreen") {
            it("can be instantiated") {
                let screen = HomeScreen()
                expect(screen).toNot(beNil())
            }
        }

        describe("HomeScreenMock") {
            it("can be instantiated as a test double") {
                let mock = HomeScreenMock()
                expect(mock).toNot(beNil())
            }
        }
    }
}
