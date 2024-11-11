//
//  ApplicationSpec.swift
//

import Foundation
import Nimble
import Quick

final class ApplicationSpec: KIFSpec {

    override class func spec() {

        describe("a TemplateApp screen") {

            beforeEach {
                // Navigate to the testing screen
            }

            afterEach {
                // Navigate to neutral state
            }

            context("when opens") {

                it("shows its UI components") {
                    tester().waitForView(withAccessibilityLabel: "Hello, world!")
                }
            }
        }
    }
}
