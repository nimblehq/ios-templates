//
//  AppVersion.swift
//

import Foundation

public struct AppVersion: Comparable, Equatable, Sendable {

    public let major: Int
    public let minor: Int
    public let patch: Int

    public init(major: Int, minor: Int, patch: Int) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }

    /// Parses a version string in "major.minor.patch" or "major.minor" format.
    public init?(string: String) {
        let parts = string
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: ".", maxSplits: 3)

        guard parts.count >= 2,
              let major = Int(parts[0]),
              let minor = Int(parts[1]) else { return nil }

        self.major = major
        self.minor = minor
        self.patch = parts.count >= 3 ? (Int(parts[2]) ?? 0) : 0
    }

    public static func < (lhs: AppVersion, rhs: AppVersion) -> Bool {
        if lhs.major != rhs.major { return lhs.major < rhs.major }
        if lhs.minor != rhs.minor { return lhs.minor < rhs.minor }
        return lhs.patch < rhs.patch
    }
}

extension AppVersion: RemoteConfigValueConvertible {

    public static func makeRemoteConfigValue(from storedValue: RemoteConfigStoredValue) -> AppVersion? {
        guard case .string(let string) = storedValue else { return nil }
        return AppVersion(string: string)
    }
}

extension RemoteConfigKey where Value == AppVersion {

    /// Remote config key for the minimum supported app version.
    /// The default value of 1.0.0 means no force update is triggered when remote config is unavailable.
    public static let minimumAppVersion = RemoteConfigKey(
        name: "minimum_app_version",
        defaultValue: AppVersion(major: 1, minor: 0, patch: 0)
    )
}
