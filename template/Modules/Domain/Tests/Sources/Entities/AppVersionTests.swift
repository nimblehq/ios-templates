import Foundation
import Testing

@testable import Domain

@Suite("AppVersion")
struct AppVersionTests {

    // MARK: - Parsing

    @Test("parses major.minor.patch string")
    func parsesMajorMinorPatchString() {
        let version = AppVersion(string: "2.3.4")

        #expect(version?.major == 2)
        #expect(version?.minor == 3)
        #expect(version?.patch == 4)
    }

    @Test("parses major.minor string with patch defaulting to zero")
    func parsesMajorMinorStringWithPatchDefaultingToZero() {
        let version = AppVersion(string: "1.5")

        #expect(version?.major == 1)
        #expect(version?.minor == 5)
        #expect(version?.patch == 0)
    }

    @Test("trims surrounding whitespace when parsing")
    func trimsSurroundingWhitespaceWhenParsing() {
        #expect(AppVersion(string: " 1.0.0 ") != nil)
    }

    @Test("returns nil for invalid strings")
    func returnsNilForInvalidStrings() {
        #expect(AppVersion(string: "") == nil)
        #expect(AppVersion(string: "abc") == nil)
        #expect(AppVersion(string: "1") == nil)
        #expect(AppVersion(string: "1.a.0") == nil)
    }

    // MARK: - Comparison

    @Test("lower major version is less than higher major version")
    func lowerMajorVersionIsLessThanHigherMajorVersion() {
        let v1 = AppVersion(major: 1, minor: 0, patch: 0)
        let v2 = AppVersion(major: 2, minor: 0, patch: 0)

        #expect(v1 < v2)
    }

    @Test("lower minor version is less than higher minor version when major is equal")
    func lowerMinorVersionIsLessThanHigherMinorVersionWhenMajorIsEqual() {
        let v1 = AppVersion(major: 1, minor: 2, patch: 0)
        let v2 = AppVersion(major: 1, minor: 3, patch: 0)

        #expect(v1 < v2)
    }

    @Test("lower patch version is less than higher patch version when major and minor are equal")
    func lowerPatchVersionIsLessThanHigherPatchVersionWhenMajorAndMinorAreEqual() {
        let v1 = AppVersion(major: 1, minor: 0, patch: 4)
        let v2 = AppVersion(major: 1, minor: 0, patch: 5)

        #expect(v1 < v2)
    }

    @Test("equal versions are not less than each other")
    func equalVersionsAreNotLessThanEachOther() {
        let v1 = AppVersion(major: 1, minor: 2, patch: 3)
        let v2 = AppVersion(major: 1, minor: 2, patch: 3)

        #expect(!(v1 < v2))
        #expect(!(v2 < v1))
        #expect(v1 == v2)
    }

    // MARK: - RemoteConfigValueConvertible

    @Test("creates AppVersion from string stored value")
    func createsAppVersionFromStringStoredValue() {
        let version = AppVersion.makeRemoteConfigValue(from: .string("3.1.2"))

        #expect(version == AppVersion(major: 3, minor: 1, patch: 2))
    }

    @Test("returns nil for non-string stored values")
    func returnsNilForNonStringStoredValues() {
        #expect(AppVersion.makeRemoteConfigValue(from: .bool(true)) == nil)
        #expect(AppVersion.makeRemoteConfigValue(from: .int(1)) == nil)
        #expect(AppVersion.makeRemoteConfigValue(from: .double(1.0)) == nil)
    }

    @Test("returns nil for unparseable string stored value")
    func returnsNilForUnparseableStringStoredValue() {
        #expect(AppVersion.makeRemoteConfigValue(from: .string("not-a-version")) == nil)
    }
}
