//
//  ApplicationLaunchUITests.swift
//

import XCTest

@MainActor
final class ApplicationLaunchUITests: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
    }

    func testLaunchDisplaysHomeScreen() {
        let application = XCUIApplication()
        application.launch()

        XCTAssertTrue(
            application.staticTexts["Hello, world!"].waitForExistence(timeout: 5),
            "Home screen should show the template greeting after launch."
        )
    }
}

