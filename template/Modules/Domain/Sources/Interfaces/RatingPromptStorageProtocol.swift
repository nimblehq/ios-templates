import Foundation

/// Protocol for managing rating prompt data persistence
public protocol RatingPromptStorageProtocol: Sendable {
    
    /// Retrieves current rating prompt data
    func getRatingPromptData() -> RatingPromptData
    
    /// Increments app launch count and sets first launch date if needed
    func recordAppLaunch()
    
    /// Increments significant event count
    func recordSignificantEvent()
    
    /// Records that user was prompted for rating on current version
    func recordPromptShown(for appVersion: String)
    
    /// Resets tracking counters (typically called after prompt is shown)
    func resetCounters()
    
    /// Clears all rating prompt related data
    func clearAllData()
}
