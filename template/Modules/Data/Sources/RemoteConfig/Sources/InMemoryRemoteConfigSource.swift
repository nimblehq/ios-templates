//
//  InMemoryRemoteConfigSource.swift
//

import Domain

actor InMemoryRemoteConfigSource: RemoteConfigSource {

    private let values: [String: RemoteConfigStoredValue]

    init(values: [String: RemoteConfigStoredValue] = [:]) {
        self.values = values
    }

    func refresh() async throws {}

    func value(forKey key: String) async -> RemoteConfigStoredValue? {
        values[key]
    }
}
