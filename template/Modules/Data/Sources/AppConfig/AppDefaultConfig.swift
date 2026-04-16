//
//  AppDefaultConfig.swift
//

import Foundation

/// Wraps an arbitrary key-value dictionary to be loaded as Firebase Remote Config defaults.
public struct AppDefaultConfig: Encodable {

    public var configs: [AnyCodingKey: any Encodable]

    public init(configs: [AnyCodingKey: any Encodable] = [:]) {
        self.configs = configs
    }

    public static func build(
        configs: [String: any Encodable] = [:],
        additionalConfigs: [AnyCodingKey: any Encodable] = [:]
    ) -> AppDefaultConfig {
        var keyed: [AnyCodingKey: any Encodable] = additionalConfigs
        for (key, value) in configs {
            keyed[AnyCodingKey(stringValue: key)] = value
        }
        return AppDefaultConfig(configs: keyed)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: AnyCodingKey.self)
        for (key, value) in configs {
            try container.encode(AnyEncodable(value), forKey: key)
        }
    }
}

// MARK: - AnyEncodable helper

private struct AnyEncodable: Encodable {

    let value: any Encodable

    init(_ value: any Encodable) {
        self.value = value
    }

    func encode(to encoder: any Encoder) throws {
        try value.encode(to: encoder)
    }
}