import Foundation
import Testing

@testable import Domain

@Suite("RemoteConfigValueConvertible")
struct RemoteConfigValueConvertibleTests {

    @Test("Bool converts supported string values")
    func boolConvertsSupportedStringValues() {
        #expect(Bool.makeRemoteConfigValue(from: .string("true")) == true)
        #expect(Bool.makeRemoteConfigValue(from: .string("off")) == false)
    }

    @Test("Bool converts numeric values")
    func boolConvertsNumericValues() {
        #expect(Bool.makeRemoteConfigValue(from: .int(1)) == true)
        #expect(Bool.makeRemoteConfigValue(from: .double(0)) == false)
    }

    @Test("Bool does not convert non-finite doubles")
    func boolDoesNotConvertNonFiniteDoubles() {
        #expect(Bool.makeRemoteConfigValue(from: .double(.nan)) == nil)
        #expect(Bool.makeRemoteConfigValue(from: .double(.infinity)) == nil)
        #expect(Bool.makeRemoteConfigValue(from: .double(-.infinity)) == nil)
    }

    @Test("Double converts string values")
    func doubleConvertsStringValues() {
        #expect(Double.makeRemoteConfigValue(from: .string("1.5")) == 1.5)
    }

    @Test("Int and Double convert data values with surrounding whitespace")
    func intAndDoubleConvertDataValuesWithSurroundingWhitespace() {
        #expect(Int.makeRemoteConfigValue(from: .data(Data(" 42 \n".utf8))) == 42)
        #expect(Double.makeRemoteConfigValue(from: .data(Data(" \t3.14 \n".utf8))) == 3.14)
    }
}
