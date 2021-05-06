//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  ___COPYRIGHT___
//

import Nimble
import Quick

class ___VARIABLE_moduleName___FlowSpec: QuickSpec {

    override func spec() {

        var app: XCUIApplication!

        describe("a ___PROJECTNAME___ app") {

            context("when go through ___VARIABLE_moduleName___ flow successfully") {

                beforeEach {
                    app = XCUIApplication()
                    app.launch()
                    Screen.___VARIABLE_moduleName___(in: app).tapTableView()
                }

                afterEach {
                    app.terminate()
                }

                it("shows ___VARIABLE_moduleName___ screen") {
                    expect(Screen.___VARIABLE_moduleName___(in: app).findDomain().exists).toEventually(beTrue())
                }
            }
        }
    }
}
