public protocol AnalyticsProtocol: AnyObject {
    
    // MARK: - Setup
    
    func configure(trackers: [AnalyticsTracker], additionalParameters: [String: Any]?)
    func addTracker(_ tracker: AnalyticsTracker, additionalParameters: [String: Any]?)
    
    // MARK: - Event Tracking
    
    func trackEvent(name: String, parameters: [String: Any]?)
    func trackEvent(name: String, parameters: [String: Any]?, on trackerTypes: [AnalyticsTrackerType])
    func trackEvent(_ event: AnalyticsEvent)
    func trackEvent(_ event: AnalyticsEvent, on trackerTypes: [AnalyticsTrackerType])
    
    // MARK: - Screen Tracking
    
    func trackScreen(name: String, screenClass: String?)
    func trackScreen(name: String, screenClass: String?, on trackerTypes: [AnalyticsTrackerType])
    
    // MARK: - User Properties
    
    func setUserProperty(key: String, value: String)
    func setUserProperty(key: String, value: String, on trackerTypes: [AnalyticsTrackerType])
    func setUserId(_ userId: String?)
    func setUserId(_ userId: String?, on trackerTypes: [AnalyticsTrackerType])
    
    // MARK: - Utility
    
    func tracker(for type: AnalyticsTrackerType) -> AnalyticsTracker?
}

// MARK: - Default Parameters

public extension AnalyticsProtocol {
    
    func configure(trackers: [AnalyticsTracker]) {
        configure(trackers: trackers, additionalParameters: nil)
    }
    
    func addTracker(_ tracker: AnalyticsTracker) {
        addTracker(tracker, additionalParameters: nil)
    }
    
    func trackEvent(name: String) {
        trackEvent(name: name, parameters: nil)
    }
    
    func trackScreen(name: String) {
        trackScreen(name: name, screenClass: nil)
    }
}
