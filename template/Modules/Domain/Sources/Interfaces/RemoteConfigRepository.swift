//
//  RemoteConfigRepository.swift
//

public protocol RemoteConfigRepository: Sendable {

    func refresh() async throws

    func value<Value: RemoteConfigValueConvertible>(for key: RemoteConfigKey<Value>) async -> Value
}
