//
//  FeatureFlag.swift
//

public struct FeatureFlag: Hashable, Sendable {

    public let name: String
    public let defaultValue: Bool

    public init(name: String, defaultValue: Bool = false) {
        self.name = name
        self.defaultValue = defaultValue
    }

    public var remoteConfigKey: RemoteConfigKey<Bool> {
        RemoteConfigKey(name: name, defaultValue: defaultValue)
    }
}
