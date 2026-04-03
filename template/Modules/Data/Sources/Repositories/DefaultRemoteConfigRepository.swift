//
//  DefaultRemoteConfigRepository.swift
//

import Domain

public protocol RemoteConfigSource: Sendable {

    func refresh() async throws

    func value(forKey key: String) async -> RemoteConfigStoredValue?
}

public actor DefaultRemoteConfigRepository: RemoteConfigRepository {

    private let source: any RemoteConfigSource

    public init(source: any RemoteConfigSource) {
        self.source = source
    }

    public func refresh() async throws {
        try await source.refresh()
    }

    public func value<Value: RemoteConfigValueConvertible>(for key: RemoteConfigKey<Value>) async -> Value {
        guard let storedValue = await source.value(forKey: key.name),
              let value = Value.makeRemoteConfigValue(from: storedValue) else {
            return key.defaultValue
        }

        return value
    }
}
