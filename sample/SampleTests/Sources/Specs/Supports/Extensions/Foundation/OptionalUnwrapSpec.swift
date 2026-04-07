//
//  OptionalUnwrapSpec.swift
//

import Nimble
import Quick

@testable import Sample

final class OptionalUnwrapSpec: QuickSpec {

    override class func spec() {

        describe("an string optional") {
            context("when value is not nil") {
                it("returns string with unwrap value") {
                    let value: String? = "hello world"
                    expect(value.string) == "hello world"
                }
            }

            context("when value is nil") {
                it("returns empty string") {
                    let value: String? = nil
                    expect(value.string.isEmpty) == true
                }
            }
        }
    }
}
