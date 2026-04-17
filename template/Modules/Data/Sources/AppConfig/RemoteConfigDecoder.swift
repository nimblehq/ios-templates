//
//  RemoteConfigDecoder.swift
//

import FirebaseRemoteConfig
import Foundation

/// A thin helper that wraps a live `RemoteConfig` instance and exposes type-safe decoding
/// utilities.  Pass it to the `configMapper` closure of `AppConfig` to decode your
/// project-specific config values.
public struct RemoteConfigDecoder {

    private let remoteConfig: RemoteConfig

    public init(remoteConfig: RemoteConfig) {
        self.remoteConfig = remoteConfig
    }

    public func allKeys(from source: FirebaseRemoteConfig.RemoteConfigSource) -> [String] {
        remoteConfig.allKeys(from: source)
    }

    public func decodeValue<Value: Decodable>(
        for key: CodingKey,
        asType type: Value.Type = Value.self
    ) -> Value? {
        do {
            let value = try remoteConfig[key.stringValue].decoded(asType: type)
            log("Decoded \(key.stringValue)")
            return value
        } catch {
            log("Failed to decode \(key.stringValue): \(error)")
            return nil
        }
    }

    public func decodeData(forKey keyString: String) -> Data? {
        let data = remoteConfig[keyString].dataValue
        guard !data.isEmpty else {
            log("No data for key: \(keyString)")
            return nil
        }
        log("Decoded data for \(keyString)")
        return data
    }

    public func decodeString(forKey keyString: String) -> String? {
        let value = remoteConfig[keyString].stringValue
        guard !value.isEmpty else {
            log("No string value for key: \(keyString)")
            return nil
        }
        log("Decoded string for \(keyString)")
        return value
    }

    public func decodeBool(forKey keyString: String) -> Bool {
        let value = remoteConfig[keyString].boolValue
        log("Decoded bool for \(keyString): \(value)")
        return value
    }

    public func decodeNumber(forKey keyString: String) -> NSNumber? {
        let value = remoteConfig[keyString].numberValue
        log("Decoded number for \(keyString): \(value)")
        return value
    }

    private func log(_ message: String) {
        #if DEBUG || DEV
            NSLog("[AppConfig] \(message).")
        #endif
    }
}