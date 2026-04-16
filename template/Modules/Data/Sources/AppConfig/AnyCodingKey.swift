//
//  AnyCodingKey.swift
//

import Foundation

/// A flexible `CodingKey` backed by a plain string or integer.
/// Use this for brand-specific remote config keys instead of a fixed enum.
public struct AnyCodingKey: CodingKey, Hashable {

    public let stringValue: String
    public let intValue: Int?

    public init(stringValue: String) {
        self.stringValue = stringValue
        intValue = nil
    }

    public init(intValue: Int) {
        stringValue = "\(intValue)"
        self.intValue = intValue
    }

    public init<Key>(_ base: Key) where Key: CodingKey {
        if let intValue = base.intValue {
            self.init(intValue: intValue)
        } else {
            self.init(stringValue: base.stringValue)
        }
    }
}