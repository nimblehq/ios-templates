//
//  FeatureFlagRepository.swift
//

public protocol FeatureFlagRepository: Sendable {

    func refresh() async throws

    func isEnabled(_ featureFlag: FeatureFlag) async -> Bool
}
