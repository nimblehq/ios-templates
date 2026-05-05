import Foundation

/// Data model representing rating prompt tracking information
public struct RatingPromptData: Codable, Sendable {
    
    /// Number of times the app has been launched
    public let appLaunchCount: Int
    
    /// Date when the app was first launched
    public let firstLaunchDate: Date?
    
    /// App version when user was last prompted for rating
    public let lastPromptedVersion: String?
    
    /// Number of significant events tracked
    public let significantEventCount: Int
    
    public init(
        appLaunchCount: Int = 0,
        firstLaunchDate: Date? = nil,
        lastPromptedVersion: String? = nil,
        significantEventCount: Int = 0
    ) {
        self.appLaunchCount = appLaunchCount
        self.firstLaunchDate = firstLaunchDate
        self.lastPromptedVersion = lastPromptedVersion
        self.significantEventCount = significantEventCount
    }
}

// MARK: - Helper Methods

public extension RatingPromptData {
    
    var daysSinceFirstLaunch: Int {
        guard let firstLaunchDate else { return 0 }
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day], from: firstLaunchDate, to: now)
        return components.day ?? 0
    }
    
    func hasBeenPromptedForCurrentVersion(_ currentVersion: String) -> Bool {
        guard let lastPromptedVersion else { return false }
        return lastPromptedVersion == currentVersion
    }
}
