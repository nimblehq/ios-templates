import Testing

@testable import {PROJECT_NAME}

@Suite("Optional+Unwrap")
struct OptionalUnwrapTests {

    @Test("returns the wrapped value when the optional contains a string")
    func returnsTheWrappedValueWhenTheOptionalContainsAString() {
        let value: String? = "hello world"

        #expect(value.string == "hello world")
    }

    @Test("returns an empty string when the optional is nil")
    func returnsAnEmptyStringWhenTheOptionalIsNil() {
        let value: String? = nil

        #expect(value.string.isEmpty)
    }
}
