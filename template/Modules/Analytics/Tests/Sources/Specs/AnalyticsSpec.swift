import Testing
@testable import Analytics

@Suite("Analytics Tests")
struct AnalyticsTests {
    
    // MARK: - Singleton Tests
    
    @Test("Analytics should be a singleton")
    func analyticsSingleton() {
        let instance1 = Analytics.shared
        let instance2 = Analytics.shared
        
        #expect(instance1 === instance2)
    }
    
    @Test("Analytics should conform to AnalyticsProtocol")
    func analyticsProtocolConformance() {
        let analytics = Analytics.shared
        #expect(analytics is AnalyticsProtocol)
    }
    
    // MARK: - Configuration Tests
    
    @Test("Configure trackers with additional parameters")
    func configureTrackersWithParameters() {
        let sut = Analytics()
        let mockConsoleTracker = MockAnalyticsTracker(type: .console)
        let additionalParams = ["app_version": "1.0.0", "build": "123"]
        
        sut.configure(trackers: [mockConsoleTracker], additionalParameters: additionalParams)
        
        #expect(mockConsoleTracker.isSetUp)
        #expect(mockConsoleTracker.setupParameters as? [String: String] == additionalParams)
    }
    
    @Test("Add individual trackers")
    func addIndividualTracker() {
        let sut = Analytics()
        let mockTracker = MockAnalyticsTracker(type: .console)
        let params = ["test": "value"]
        
        sut.addTracker(mockTracker, additionalParameters: params)
        
        #expect(mockTracker.isSetUp)
        #expect(mockTracker.setupParameters as? [String: String] == params)
    }
    
    // MARK: - Event Tracking Tests
    
    @Test("Track events on all trackers by default")
    func trackEventOnAllTrackers() {
        let sut = Analytics()
        let mockConsoleTracker = MockAnalyticsTracker(type: .console)
        
        sut.configure(trackers: [mockConsoleTracker])
        sut.trackEvent(name: "user_login", parameters: ["method": "email"])
        
        #expect(mockConsoleTracker.hasTrackedEvent(name: "user_login"))
        
        let consoleEvent = mockConsoleTracker.trackedEvents.first
        #expect(consoleEvent?.parameters?["method"] as? String == "email")
    }
    
    @Test("Track events on specific trackers")
    func trackEventOnSpecificTrackers() {
        let sut = Analytics()
        let mockConsoleTracker = MockAnalyticsTracker(type: .console)
        
        sut.configure(trackers: [mockConsoleTracker])
        sut.trackEvent(name: "purchase", parameters: ["amount": 9.99], on: [.console])
        
        #expect(mockConsoleTracker.hasTrackedEvent(name: "purchase"))
    }
    
    @Test("Track events without parameters")
    func trackEventWithoutParameters() {
        let sut = Analytics()
        let mockConsoleTracker = MockAnalyticsTracker(type: .console)
        
        sut.configure(trackers: [mockConsoleTracker])
        sut.trackEvent(name: "app_open")
        
        #expect(mockConsoleTracker.hasTrackedEvent(name: "app_open"))
    }
    
    @Test("Track structured events")
    func trackStructuredEvent() {
        let sut = Analytics()
        let mockTracker = MockAnalyticsTracker(type: .console)
        
        sut.configure(trackers: [mockTracker])
        
        let loginEvent = UserLoginEvent(loginMethod: "email", isSuccessful: true)
        sut.trackEvent(loginEvent)
        
        #expect(mockTracker.hasTrackedEvent(name: "user_login"))
        let event = mockTracker.trackedEvents.first
        #expect(event?.parameters?["login_method"] as? String == "email")
        #expect(event?.parameters?["is_successful"] as? Bool == true)
    }
    
    // MARK: - Screen Tracking Tests
    
    @Test("Track screens on all trackers by default")
    func trackScreenOnAllTrackers() {
        let sut = Analytics()
        let mockConsoleTracker = MockAnalyticsTracker(type: .console)
        
        sut.configure(trackers: [mockConsoleTracker])
        sut.trackScreen(name: "HomeScreen", screenClass: "HomeViewController")
        
        #expect(mockConsoleTracker.hasTrackedScreen(name: "HomeScreen"))
    }
    
    @Test("Track screens on specific trackers")
    func trackScreenOnSpecificTrackers() {
        let sut = Analytics()
        let mockConsoleTracker = MockAnalyticsTracker(type: .console)
        
        sut.configure(trackers: [mockConsoleTracker])
        sut.trackScreen(name: "ProfileScreen", screenClass: nil, on: [.console])
        
        #expect(mockConsoleTracker.hasTrackedScreen(name: "ProfileScreen"))
    }
    
    // MARK: - User Properties Tests
    
    @Test("Set user properties on all trackers by default")
    func setUserPropertyOnAllTrackers() {
        let sut = Analytics()
        let mockConsoleTracker = MockAnalyticsTracker(type: .console)
        
        sut.configure(trackers: [mockConsoleTracker])
        sut.setUserProperty(key: "subscription_type", value: "premium")
        
        #expect(mockConsoleTracker.userProperties["subscription_type"] == "premium")
    }
    
    @Test("Set user properties on specific trackers")
    func setUserPropertyOnSpecificTrackers() {
        let sut = Analytics()
        let mockConsoleTracker = MockAnalyticsTracker(type: .console)
        
        sut.configure(trackers: [mockConsoleTracker])
        sut.setUserProperty(key: "age_group", value: "25-34", on: [.console])
        
        #expect(mockConsoleTracker.userProperties["age_group"] == "25-34")
    }
    
    @Test("Set user ID on all trackers by default")
    func setUserIdOnAllTrackers() {
        let sut = Analytics()
        let mockConsoleTracker = MockAnalyticsTracker(type: .console)
        
        sut.configure(trackers: [mockConsoleTracker])
        sut.setUserId("user_12345")
        
        #expect(mockConsoleTracker.userId == "user_12345")
    }
    
    // MARK: - Tracker Utility Tests
    
    @Test("Return specific tracker by type")
    func getTrackerByType() {
        let sut = Analytics()
        let mockConsoleTracker = MockAnalyticsTracker(type: .console)
        
        sut.configure(trackers: [mockConsoleTracker])
        
        let consoleTracker = sut.tracker(for: .console)

        #expect(consoleTracker != nil)
        #expect(consoleTracker?.type == .console)
    }
}
