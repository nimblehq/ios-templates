public final class Analytics: AnalyticsProtocol {
    
    public static let shared: AnalyticsProtocol = Analytics()
    
    private var trackers: [AnalyticsTracker] = []
    
    private init() {}
    
    // MARK: - Setup
    
    public func configure(trackers: [AnalyticsTracker], additionalParameters: [String: Any]? = nil) {
        self.trackers = trackers
        trackers.forEach { $0.setUp(additionalParameters: additionalParameters) }
    }
    
    public func addTracker(_ tracker: AnalyticsTracker, additionalParameters: [String: Any]? = nil) {
        trackers.append(tracker)
        tracker.setUp(additionalParameters: additionalParameters)
    }
    
    // MARK: - Event Tracking
    
    public func trackEvent(name: String, parameters: [String: Any]?) {
        trackEvent(name: name, parameters: parameters, on: AnalyticsTrackerType.allCases)
    }
    
    public func trackEvent(name: String, parameters: [String: Any]?, on trackerTypes: [AnalyticsTrackerType]) {
        let targetTrackers = trackers.filter { trackerTypes.contains($0.type) }
        targetTrackers.forEach { $0.trackEvent(name: name, parameters: parameters) }
    }
    
    public func trackEvent(_ event: AnalyticsEvent) {
        trackEvent(event, on: AnalyticsTrackerType.allCases)
    }
    
    public func trackEvent(_ event: AnalyticsEvent, on trackerTypes: [AnalyticsTrackerType]) {
        trackEvent(name: event.name, parameters: event.parameters, on: trackerTypes)
    }
    
    // MARK: - Screen Tracking
    
    public func trackScreen(name: String, screenClass: String?) {
        trackScreen(name: name, screenClass: screenClass, on: AnalyticsTrackerType.allCases)
    }
    
    public func trackScreen(name: String, screenClass: String?, on trackerTypes: [AnalyticsTrackerType]) {
        let targetTrackers = trackers.filter { trackerTypes.contains($0.type) }
        targetTrackers.forEach { $0.trackScreen(name: name, screenClass: screenClass) }
    }
    
    // MARK: - User Properties
    
    public func setUserProperty(key: String, value: String) {
        setUserProperty(key: key, value: value, on: AnalyticsTrackerType.allCases)
    }
    
    public func setUserProperty(key: String, value: String, on trackerTypes: [AnalyticsTrackerType]) {
        let targetTrackers = trackers.filter { trackerTypes.contains($0.type) }
        targetTrackers.forEach { $0.setUserProperty(key: key, value: value) }
    }
    
    public func setUserId(_ userId: String?) {
        setUserId(userId, on: AnalyticsTrackerType.allCases)
    }
    
    public func setUserId(_ userId: String?, on trackerTypes: [AnalyticsTrackerType]) {
        let targetTrackers = trackers.filter { trackerTypes.contains($0.type) }
        targetTrackers.forEach { $0.setUserId(userId) }
    }
    
    // MARK: - Utility
    
    public func tracker(for type: AnalyticsTrackerType) -> AnalyticsTracker? {
        trackers.first { $0.type == type }
    }
}
