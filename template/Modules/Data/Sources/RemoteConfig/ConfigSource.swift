//
//  ConfigSource.swift
//

import Domain

public protocol ConfigSource: Sendable {

    func refresh() async throws

    func value(forKey key: String) async -> RemoteConfigStoredValue?
}
