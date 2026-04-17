//
//  FirebaseRemoteConfigSource.swift
//

import Domain
import FirebaseRemoteConfig
import Foundation

// MARK: - RemoteConfigInterface

/// Abstracts the Firebase `RemoteConfig` API surface used by `FirebaseRemoteConfigSource`,
/// enabling the class to be tested without subclassing the Firebase singleton.
protocol RemoteConfigInterface {
    func fetchAndActivate(completionHandler: ((RemoteConfigFetchAndActivateStatus, (any Error)?) -> Void)?)
    func configEntry(forKey key: String) -> (data: Data, source: FirebaseRemoteConfig.RemoteConfigSource)
}

extension RemoteConfig: RemoteConfigInterface {
    func configEntry(forKey key: String) -> (data: Data, source: FirebaseRemoteConfig.RemoteConfigSource) {
        let value = self[key]
        return (value.dataValue, value.source)
    }
}

// MARK: - FirebaseRemoteConfigSource

/// Firebase Remote Config implementation of `RemoteConfigSource` protocol.
/// Bridges Firebase Remote Config to the existing Domain layer interface.
public final class FirebaseRemoteConfigSource: RemoteConfigSource {

    private let remoteConfig: any RemoteConfigInterface

    public convenience init(remoteConfig: RemoteConfig = RemoteConfig.remoteConfig()) {
        self.init(config: remoteConfig)
    }

    init(config: any RemoteConfigInterface) {
        self.remoteConfig = config
    }

    public func refresh() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            remoteConfig.fetchAndActivate { _, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    public func value(forKey key: String) async -> RemoteConfigStoredValue? {
        let (data, source) = remoteConfig.configEntry(forKey: key)

        guard source != .static || !data.isEmpty else {
            return nil
        }

        guard !data.isEmpty else {
            return nil
        }
        
        if let string = String(data: data, encoding: .utf8) {
            if let boolValue = string.normalizedRemoteConfigBoolean {
                return .bool(boolValue)
            }
            
            if let intValue = Int(string.trimmingCharacters(in: .whitespacesAndNewlines)) {
                return .int(intValue)
            }
            
            if let doubleValue = Double(string.trimmingCharacters(in: .whitespacesAndNewlines)) {
                return .double(doubleValue)
            }
            
            return .string(string)
        }
        
        return .data(data)
    }
}

// MARK: - String extension for boolean parsing

private extension String {

    var normalizedRemoteConfigBoolean: Bool? {
        switch trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "1", "true", "yes", "y", "on":
            return true
        case "0", "false", "no", "n", "off":
            return false
        default:
            return nil
        }
    }
}