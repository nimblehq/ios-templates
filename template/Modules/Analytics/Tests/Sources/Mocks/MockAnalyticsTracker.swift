@testable import Analytics

/// Mock tracker for testing purposes
final class MockAnalyticsTracker: AnalyticsTracker {
    
    let type: AnalyticsTrackerType
    
    // MARK: - Tracked Data
    
    private(set) var isSetUp = false
    private(set) var setupParameters: [String: Any]?
    private(set) var trackedEvents: [(name: String, parameters: [String: Any]?)] = []
    private(set) var trackedScreens: [(name: String, screenClass: String?)] = []
    private(set) var userProperties: [String: String] = [:]
    private(set) var userId: String?
    
    init(type: AnalyticsTrackerType) {
        self.type = type
    }
    
    // MARK: - AnalyticsTracker Implementation
    
    func setUp(additionalParameters: [String: Any]?) {
        isSetUp = true
        setupParameters = additionalParameters
    }
    
    func trackEvent(name: String, parameters: [String: Any]?) {
        trackedEvents.append((name: name, parameters: parameters))
    }
    
    func trackScreen(name: String, screenClass: String?) {
        trackedScreens.append((name: name, screenClass: screenClass))
    }
    
    func setUserProperty(key: String, value: String) {
        userProperties[key] = value
    }
    
    func setUserId(_ userId: String?) {
        self.userId = userId
    }
    
    // MARK: - Test Helpers
    
    func reset() {
        isSetUp = false
        setupParameters = nil
        trackedEvents.removeAll()
        trackedScreens.removeAll()
        userProperties.removeAll()
        userId = nil
    }
    
    func hasTrackedEvent(name: String) -> Bool {
        trackedEvents.contains { $0.name == name }
    }
    
    func hasTrackedScreen(name: String) -> Bool {
        trackedScreens.contains { $0.name == name }
    }
    
    func eventCount(for name: String) -> Int {
        trackedEvents.filter { $0.name == name }.count
    }
}
