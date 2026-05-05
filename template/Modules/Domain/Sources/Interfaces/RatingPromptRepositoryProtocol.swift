import Foundation

/// Protocol for managing rating prompt data persistence
public protocol RatingPromptRepositoryProtocol: Sendable {

    /// Retrieves current rating prompt data
    func getRatingPromptData() async -> RatingPromptData

    /// Increments app launch count and sets first launch date if needed
    func recordAppLaunch() async

    /// Increments significant event count
    func recordSignificantEvent() async

    /// Records that user was prompted for rating on current version
    func recordPromptShown(for appVersion: String) async

    /// Resets tracking counters (typically called after prompt is shown)
    func resetCounters() async

    /// Clears all rating prompt related data
    func clearAllData() async
}
