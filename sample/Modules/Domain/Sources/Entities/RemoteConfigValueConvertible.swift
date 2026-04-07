//
//  RemoteConfigValueConvertible.swift
//

import Foundation

public protocol RemoteConfigValueConvertible: Sendable {

    static func makeRemoteConfigValue(from storedValue: RemoteConfigStoredValue) -> Self?
}

extension Bool: RemoteConfigValueConvertible {

    public static func makeRemoteConfigValue(from storedValue: RemoteConfigStoredValue) -> Bool? {
        switch storedValue {
        case let .bool(value):
            value
        case let .string(value):
            value.normalizedRemoteConfigBoolean
        case let .int(value):
            value != 0
        case let .double(value):
            value != 0
        case let .data(value):
            String(data: value, encoding: .utf8)?.normalizedRemoteConfigBoolean
        }
    }
}

extension String: RemoteConfigValueConvertible {

    public static func makeRemoteConfigValue(from storedValue: RemoteConfigStoredValue) -> String? {
        switch storedValue {
        case let .bool(value):
            value.description
        case let .string(value):
            value
        case let .int(value):
            value.description
        case let .double(value):
            value.description
        case let .data(value):
            String(data: value, encoding: .utf8)
        }
    }
}

extension Int: RemoteConfigValueConvertible {

    public static func makeRemoteConfigValue(from storedValue: RemoteConfigStoredValue) -> Int? {
        switch storedValue {
        case let .bool(value):
            return value ? 1 : 0
        case let .string(value):
            return Int(value.trimmingCharacters(in: .whitespacesAndNewlines))
        case let .int(value):
            return value
        case let .double(value):
            guard value.isFinite else {
                return nil
            }
            return Int(exactly: value)
        case let .data(value):
            return String(data: value, encoding: .utf8).flatMap(Int.init)
        }
    }
}

extension Double: RemoteConfigValueConvertible {

    public static func makeRemoteConfigValue(from storedValue: RemoteConfigStoredValue) -> Double? {
        switch storedValue {
        case let .bool(value):
            value ? 1 : 0
        case let .string(value):
            Double(value.trimmingCharacters(in: .whitespacesAndNewlines))
        case let .int(value):
            Double(value)
        case let .double(value):
            value
        case let .data(value):
            String(data: value, encoding: .utf8).flatMap(Double.init)
        }
    }
}

extension Data: RemoteConfigValueConvertible {

    public static func makeRemoteConfigValue(from storedValue: RemoteConfigStoredValue) -> Data? {
        switch storedValue {
        case let .bool(value):
            value.description.data(using: .utf8)
        case let .string(value):
            value.data(using: .utf8)
        case let .int(value):
            value.description.data(using: .utf8)
        case let .double(value):
            value.description.data(using: .utf8)
        case let .data(value):
            value
        }
    }
}

private extension String {

    var normalizedRemoteConfigBoolean: Bool? {
        switch trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "1", "true", "yes", "y", "on":
            true
        case "0", "false", "no", "n", "off":
            false
        default:
            nil
        }
    }
}
