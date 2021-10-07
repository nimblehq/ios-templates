//
//  OptionalUnwrapSpec.swift
//  AddDangerTests
//
//  Created by Su Van Ho on 08/10/2021.
//  Copyright © 2021 Nimble. All rights reserved.
//

import Nimble
import Quick

@testable import AddDanger

final class OptionalUnwrapSpec: QuickSpec {

    override func spec() {
        describe("an string optional") {
            var value: String?

            context("when value is not nil") {

                beforeEach {
                    value = "hello world"
                }

                it("returns string with unwrap value") {
                    expect(value.string) == "hello world"
                }
            }

            context("when value is nil") {

                beforeEach {
                    value = nil
                }

                it("returns empty string") {
                    expect(value.string) == "-"
                }
            }
        }
    }
}
