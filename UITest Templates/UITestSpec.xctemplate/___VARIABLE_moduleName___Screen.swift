//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  ___COPYRIGHT___
//

import XCTest

extension Screen {

    final class ___VARIABLE_moduleName___: ScreenProtocol {

        typealias Identifier = AccessibilityIdentifiers.___VARIABLE_moduleName___

        let application: XCUIApplication

        init(in application: XCUIApplication) {
            self.application = application
        }

        @discardableResult
        func tapTableView() -> ___VARIABLE_moduleName___ {
            find(\.tables, withIdentifier: .tableView).tap()
            return self
        }
    }
}
