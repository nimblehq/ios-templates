//
//  InMemoryRemoteConfigSource.swift
//

import Domain

public actor InMemoryRemoteConfigSource: RemoteConfigSource {

    private let values: [String: RemoteConfigStoredValue]

    public init(values: [String: RemoteConfigStoredValue] = [:]) {
        self.values = values
    }

    public func refresh() async throws {}

    public func value(forKey key: String) async -> RemoteConfigStoredValue? {
        values[key]
    }
}
