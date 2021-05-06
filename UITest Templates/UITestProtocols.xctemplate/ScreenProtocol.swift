//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  ___COPYRIGHT___
//

import XCTest
import Nimble

protocol ScreenProtocol: AnyObject {

    associatedtype Identifier: IdentifierProvidable

    var application: XCUIApplication { get }
}

extension ScreenProtocol {

    func find(
        _ elementKey: KeyPath<XCUIApplication, XCUIElementQuery>,
        withIdentifier identifier: Identifier
    ) -> XCUIElement {
        return application[keyPath: elementKey][identifier.identifier]
    }

    func find(
        _ elementKey: KeyPath<XCUIApplication, XCUIElementQuery>,
        withString string: String
    ) -> XCUIElement {
        return application[keyPath: elementKey][string]
    }

    func findDomain() -> XCUIElement {
        return application.otherElements[Identifier.screenName]
    }

    @discardableResult
    func waitForExistence(
        timeout: TimeInterval,
        file: FileString = #file,
        line: UInt = #line
    ) -> Self {
        let isFound = application
            .otherElements[Identifier.screenName]
            .waitForExistence(timeout: timeout)

        if !isFound {
            fail(
                "\(Identifier.screenName.capitalized) screen is not found after \(timeout) seconds delay",
                file: file,
                line: line
            )
        }
        return self
    }
}
