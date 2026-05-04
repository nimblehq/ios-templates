import Testing
@testable import Analytics

@Suite("MockAnalyticsTracker Tests")
struct MockAnalyticsTrackerTests {
    
    // MARK: - Initialization Tests
    
    @Test("MockAnalyticsTracker initializes with correct type")
    func initializeWithCorrectType() {
        let sut = MockAnalyticsTracker(type: .console)
        
        #expect(sut.type == .console)
        #expect(!sut.isSetUp)
    }
    
    // MARK: - Setup Tests
    
    @Test("Track setup call with parameters")
    func trackSetupWithParameters() {
        let sut = MockAnalyticsTracker(type: .console)
        let params = ["key": "value"]
        
        sut.setUp(additionalParameters: params)
        
        #expect(sut.isSetUp)
        #expect(sut.setupParameters as? [String: String] == params)
    }
    
    @Test("Handle setup without parameters")
    func handleSetupWithoutParameters() {
        let sut = MockAnalyticsTracker(type: .console)
        
        sut.setUp(additionalParameters: nil)
        
        #expect(sut.isSetUp)
        #expect(sut.setupParameters == nil)
    }
    
    // MARK: - Event Tracking Tests
    
    @Test("Track events with parameters")
    func trackEventsWithParameters() {
        let sut = MockAnalyticsTracker(type: .console)
        
        sut.trackEvent(name: "test_event", parameters: ["param1": "value1"])
        
        #expect(sut.hasTrackedEvent(name: "test_event"))
        #expect(sut.eventCount(for: "test_event") == 1)
        
        let event = sut.trackedEvents.first
        #expect(event?.name == "test_event")
        #expect(event?.parameters?["param1"] as? String == "value1")
    }
    
    @Test("Track events without parameters")
    func trackEventsWithoutParameters() {
        let sut = MockAnalyticsTracker(type: .console)
        
        sut.trackEvent(name: "simple_event", parameters: nil)
        
        #expect(sut.hasTrackedEvent(name: "simple_event"))
        #expect(sut.trackedEvents.first?.parameters == nil)
    }
    
    @Test("Track multiple events")
    func trackMultipleEvents() {
        let sut = MockAnalyticsTracker(type: .console)
        
        sut.trackEvent(name: "event1", parameters: nil)
        sut.trackEvent(name: "event2", parameters: nil)
        sut.trackEvent(name: "event1", parameters: nil)
        
        #expect(sut.trackedEvents.count == 3)
        #expect(sut.eventCount(for: "event1") == 2)
        #expect(sut.eventCount(for: "event2") == 1)
    }
    
    // MARK: - Screen Tracking Tests
    
    @Test("Track screens with class")
    func trackScreensWithClass() {
        let sut = MockAnalyticsTracker(type: .console)
        
        sut.trackScreen(name: "HomeScreen", screenClass: "HomeViewController")
        
        #expect(sut.hasTrackedScreen(name: "HomeScreen"))
        
        let screen = sut.trackedScreens.first
        #expect(screen?.name == "HomeScreen")
        #expect(screen?.screenClass == "HomeViewController")
    }
    
    @Test("Track screens without class")
    func trackScreensWithoutClass() {
        let sut = MockAnalyticsTracker(type: .console)
        
        sut.trackScreen(name: "ProfileScreen", screenClass: nil)
        
        #expect(sut.hasTrackedScreen(name: "ProfileScreen"))
        #expect(sut.trackedScreens.first?.screenClass == nil)
    }
    
    // MARK: - User Properties Tests
    
    @Test("Set user properties")
    func setUserProperties() {
        let sut = MockAnalyticsTracker(type: .console)
        
        sut.setUserProperty(key: "subscription", value: "premium")
        sut.setUserProperty(key: "age", value: "25")
        
        #expect(sut.userProperties["subscription"] == "premium")
        #expect(sut.userProperties["age"] == "25")
    }
    
    @Test("Set user ID")
    func setUserId() {
        let sut = MockAnalyticsTracker(type: .console)
        
        sut.setUserId("user_123")
        
        #expect(sut.userId == "user_123")
    }
    
    @Test("Handle nil user ID")
    func handleNilUserId() {
        let sut = MockAnalyticsTracker(type: .console)
        
        sut.setUserId("user_123")
        sut.setUserId(nil)
        
        #expect(sut.userId == nil)
    }
    
    // MARK: - Test Helpers Tests
    
    @Test("Reset all tracked data")
    func resetAllTrackedData() {
        let sut = MockAnalyticsTracker(type: .console)
        
        // Setup some data
        sut.setUp(additionalParameters: ["key": "value"])
        sut.trackEvent(name: "test", parameters: nil)
        sut.trackScreen(name: "screen", screenClass: nil)
        sut.setUserProperty(key: "prop", value: "val")
        sut.setUserId("user")
        
        // Reset and verify
        sut.reset()
        
        #expect(!sut.isSetUp)
        #expect(sut.setupParameters == nil)
        #expect(sut.trackedEvents.isEmpty)
        #expect(sut.trackedScreens.isEmpty)
        #expect(sut.userProperties.isEmpty)
        #expect(sut.userId == nil)
    }
}
