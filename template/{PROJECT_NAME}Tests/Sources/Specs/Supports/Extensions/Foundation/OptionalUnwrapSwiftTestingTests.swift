//
//  OptionalUnwrapSwiftTestingTests.swift
//

import Testing

@testable import {PROJECT_NAME}

@Suite("Optional+Unwrap")
struct OptionalUnwrapSwiftTestingTests {

    struct StringUnwrapCase: Sendable {
        let value: String?
        let expected: String
    }

    @Test(
        "string returns the expected representation",
        arguments: [
            StringUnwrapCase(value: "hello world", expected: "hello world"),
            StringUnwrapCase(value: nil, expected: "")
        ]
    )
    func stringReturnsExpectedRepresentation(for stringUnwrapCase: StringUnwrapCase) {
        #expect(stringUnwrapCase.value.string == stringUnwrapCase.expected)
    }
}

