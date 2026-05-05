import Foundation

/// Configuration for rating prompt eligibility rules
public struct RatingPromptConfiguration: Sendable {
    
    /// Minimum number of days since first app launch before showing prompt
    public let minimumDaysSinceFirstLaunch: Int
    
    /// Minimum number of app launches before showing prompt
    public let minimumAppLaunches: Int
    
    /// Minimum number of significant events before showing prompt
    public let minimumSignificantEvents: Int
    
    /// Whether to reset counter after showing prompt in new version
    public let resetCounterAfterPrompt: Bool
    
    public init(
        minimumDaysSinceFirstLaunch: Int = 7,
        minimumAppLaunches: Int = 10,
        minimumSignificantEvents: Int = 5,
        resetCounterAfterPrompt: Bool = true
    ) {
        self.minimumDaysSinceFirstLaunch = minimumDaysSinceFirstLaunch
        self.minimumAppLaunches = minimumAppLaunches
        self.minimumSignificantEvents = minimumSignificantEvents
        self.resetCounterAfterPrompt = resetCounterAfterPrompt
    }
}
