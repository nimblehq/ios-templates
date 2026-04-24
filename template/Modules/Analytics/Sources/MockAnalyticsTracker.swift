/// Mock tracker for testing purposes
public final class MockAnalyticsTracker: AnalyticsTracker {
    
    public let type: AnalyticsTrackerType
    
    // MARK: - Tracked Data
    
    public private(set) var isSetUp = false
    public private(set) var setupParameters: [String: Any]?
    public private(set) var trackedEvents: [(name: String, parameters: [String: Any]?)] = []
    public private(set) var trackedScreens: [(name: String, screenClass: String?)] = []
    public private(set) var userProperties: [String: String] = [:]
    public private(set) var userId: String?
    
    public init(type: AnalyticsTrackerType) {
        self.type = type
    }
    
    // MARK: - AnalyticsTracker Implementation
    
    public func setUp(additionalParameters: [String: Any]?) {
        isSetUp = true
        setupParameters = additionalParameters
    }
    
    public func trackEvent(name: String, parameters: [String: Any]?) {
        trackedEvents.append((name: name, parameters: parameters))
    }
    
    public func trackScreen(name: String, screenClass: String?) {
        trackedScreens.append((name: name, screenClass: screenClass))
    }
    
    public func setUserProperty(key: String, value: String) {
        userProperties[key] = value
    }
    
    public func setUserId(_ userId: String?) {
        self.userId = userId
    }
    
    // MARK: - Test Helpers
    
    public func reset() {
        isSetUp = false
        setupParameters = nil
        trackedEvents.removeAll()
        trackedScreens.removeAll()
        userProperties.removeAll()
        userId = nil
    }
    
    public func hasTrackedEvent(name: String) -> Bool {
        trackedEvents.contains { $0.name == name }
    }
    
    public func hasTrackedScreen(name: String) -> Bool {
        trackedScreens.contains { $0.name == name }
    }
    
    public func eventCount(for name: String) -> Int {
        trackedEvents.filter { $0.name == name }.count
    }
}
