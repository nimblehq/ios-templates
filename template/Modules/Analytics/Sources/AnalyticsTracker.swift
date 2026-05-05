public protocol AnalyticsTracker {
    
    var type: AnalyticsTrackerType { get }
    
    func setUp(additionalParameters: [String: Any]?)
    func trackEvent(name: String, parameters: [String: Any]?)
    func trackScreen(name: String, screenClass: String?)
    func setUserProperty(key: String, value: String)
    func setUserId(_ userId: String?)
}

// MARK: - Extensions

public extension AnalyticsTracker {
    
    func setUp() {
        setUp(additionalParameters: nil)
    }
    
    func trackEvent(name: String) {
        trackEvent(name: name, parameters: nil)
    }
    
    func trackEvent(_ event: AnalyticsEvent) {
        trackEvent(name: event.name, parameters: event.parameters)
    }
    
    func trackScreen(name: String) {
        trackScreen(name: name, screenClass: nil)
    }
}
