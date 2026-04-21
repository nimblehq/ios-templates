//
//  ShouldShowRatingPromptUseCase.swift
//

import Foundation

public protocol ShouldShowRatingPromptUseCaseProtocol: Sendable {
    
    /// Determines if rating prompt should be shown based on configuration rules
    /// - Parameter configuration: Rules for determining eligibility
    /// - Returns: True if prompt should be shown
    func callAsFunction(configuration: RatingPromptConfiguration) -> Bool
}

public struct ShouldShowRatingPromptUseCase: ShouldShowRatingPromptUseCaseProtocol, Sendable {
    
    private let storage: any RatingPromptStorageProtocol
    private let currentVersion: String
    
    public init(
        storage: any RatingPromptStorageProtocol,
        currentVersion: String = Self.defaultCurrentVersion()
    ) {
        self.storage = storage
        self.currentVersion = currentVersion
    }
    
    public func callAsFunction(configuration: RatingPromptConfiguration) -> Bool {
        let data = storage.getRatingPromptData()
        
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

extension ShouldShowRatingPromptUseCase {
    
    public static func defaultCurrentVersion() -> String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
}
