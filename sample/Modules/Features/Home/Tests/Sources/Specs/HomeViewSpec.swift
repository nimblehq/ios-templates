import Home
import HomeTesting
import Nimble
import Quick

final class HomeViewSpec: QuickSpec {

    override class func spec() {
        describe("HomeView") {
            it("can be instantiated") {
                let view = HomeView()
                expect(view).toNot(beNil())
            }
        }

        describe("HomeViewMock") {
            it("can be instantiated as a test double") {
                let mock = HomeViewMock()
                expect(mock).toNot(beNil())
            }
        }
    }
}
