//
//  ShouldShowRatingPromptUseCase.swift
//

import Foundation

public protocol ShouldShowRatingPromptUseCaseProtocol: Sendable {
    
    /// Determines if rating prompt should be shown based on configuration rules
    /// - Parameter configuration: Rules for determining eligibility
    /// - Returns: True if prompt should be shown
    func callAsFunction(configuration: RatingPromptConfiguration) async -> Bool
}

public struct ShouldShowRatingPromptUseCase: ShouldShowRatingPromptUseCaseProtocol, Sendable {

    private let repository: any RatingPromptRepositoryProtocol
    private let currentVersion: String

    public init(
        repository: any RatingPromptRepositoryProtocol,
        currentVersion: String = Bundle.main.info.shortVersion ?? "1.0.0"
    ) {
        self.repository = repository
        self.currentVersion = currentVersion
    }

    public func callAsFunction(configuration: RatingPromptConfiguration) async -> Bool {
        let data = await repository.getRatingPromptData()
        
        guard !data.hasBeenPromptedForCurrentVersion(currentVersion) else {
            return false
        }
        
        guard data.daysSinceFirstLaunch >= configuration.minimumDaysSinceFirstLaunch else {
            return false
        }
        
        let hasEnoughAppLaunches = data.appLaunchCount >= configuration.minimumAppLaunches
        let hasEnoughSignificantEvents = data.significantEventCount >= configuration.minimumSignificantEvents
        
        return hasEnoughAppLaunches || hasEnoughSignificantEvents
    }
}
