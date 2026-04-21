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
        
        if data.hasBeenPromptedForCurrentVersion(currentVersion) {
            return false
        }
        
        let daysSinceFirstLaunch = data.daysSinceFirstLaunch
        guard daysSinceFirstLaunch >= configuration.minimumDaysSinceFirstLaunch else {
            return false
        }
        
        guard data.appLaunchCount >= configuration.minimumAppLaunches else {
            return false
        }
        
        guard data.significantEventCount >= configuration.minimumSignificantEvents else {
            return false
        }
        
        return true
    }
}

extension ShouldShowRatingPromptUseCase {
    
    public static func defaultCurrentVersion() -> String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
}
