//
//  RemoteConfigKey.swift
//

public struct RemoteConfigKey<Value: RemoteConfigValueConvertible>: Sendable {

    public let name: String
    public let defaultValue: Value

    public init(name: String, defaultValue: Value) {
        self.name = name
        self.defaultValue = defaultValue
    }
}
