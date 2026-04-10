//
//  DefaultFeatureFlagRepository.swift
//

import Domain
import FactoryKit

public struct DefaultFeatureFlagRepository: FeatureFlagRepository, Sendable {

    @Injected(\.remoteConfigRepository) private var remoteConfigRepository: any RemoteConfigRepository

    public init() {}

    public func refresh() async throws {
        try await remoteConfigRepository.refresh()
    }

    public func isEnabled(_ featureFlag: FeatureFlag) async -> Bool {
        await remoteConfigRepository.value(for: featureFlag.remoteConfigKey)
    }
}
