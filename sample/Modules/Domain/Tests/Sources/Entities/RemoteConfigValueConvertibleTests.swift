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

    @Test("Double converts string values")
    func doubleConvertsStringValues() {
        #expect(Double.makeRemoteConfigValue(from: .string("1.5")) == 1.5)
    }
}
