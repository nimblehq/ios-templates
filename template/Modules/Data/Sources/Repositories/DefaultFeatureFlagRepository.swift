//
//  DefaultFeatureFlagRepository.swift
//

import Domain

public struct DefaultFeatureFlagRepository: FeatureFlagRepository, Sendable {

    private let remoteConfigRepository: any RemoteConfigRepository

    public init(remoteConfigRepository: any RemoteConfigRepository) {
        self.remoteConfigRepository = remoteConfigRepository
    }

    public func refresh() async throws {
        try await remoteConfigRepository.refresh()
    }

    public func isEnabled(_ featureFlag: FeatureFlag) async -> Bool {
        await remoteConfigRepository.value(for: featureFlag.remoteConfigKey)
    }
}
