//
//  RemoteConfigSource.swift
//

import Domain

public protocol RemoteConfigSource: Sendable {

    func refresh() async throws

    func value(forKey key: String) async -> RemoteConfigStoredValue?
}
