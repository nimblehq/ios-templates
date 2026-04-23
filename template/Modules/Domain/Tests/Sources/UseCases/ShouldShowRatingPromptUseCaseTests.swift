import Foundation
import Testing

@testable import Domain

@Suite("ShouldShowRatingPromptUseCase")
struct ShouldShowRatingPromptUseCaseTests {

    @Test("returns false when user has already been prompted for current version")
    func returnsFalseWhenUserHasAlreadyBeenPromptedForCurrentVersion() {
        let storage = StubRatingPromptStorage(
            data: RatingPromptData(
                appLaunchCount: 20,
                firstLaunchDate: Date().addingTimeInterval(-10 * 24 * 60 * 60), // 10 days ago
                lastPromptedVersion: "1.0.0",
                significantEventCount: 10
            )
        )
        let useCase = ShouldShowRatingPromptUseCase(
            storage: storage,
            currentVersion: "1.0.0"
        )
        let configuration = RatingPromptConfiguration(
            minimumDaysSinceFirstLaunch: 7,
            minimumAppLaunches: 10,
            minimumSignificantEvents: 5
        )
        
        let result = useCase(configuration: configuration)
        
        #expect(result == false)
    }
    
    @Test("returns true when user has been prompted for different version")
    func returnsTrueWhenUserHasBeenPromptedForDifferentVersion() {
        let storage = StubRatingPromptStorage(
            data: RatingPromptData(
                appLaunchCount: 20,
                firstLaunchDate: Date().addingTimeInterval(-10 * 24 * 60 * 60), // 10 days ago
                lastPromptedVersion: "1.0.0",
                significantEventCount: 10
            )
        )
        let useCase = ShouldShowRatingPromptUseCase(
            storage: storage,
            currentVersion: "1.1.0"
        )
        let configuration = RatingPromptConfiguration(
            minimumDaysSinceFirstLaunch: 7,
            minimumAppLaunches: 10,
            minimumSignificantEvents: 5
        )
        
        let result = useCase(configuration: configuration)
        
        #expect(result == true)
    }
    
    @Test("returns false when not enough days have passed since first launch")
    func returnsFalseWhenNotEnoughDaysHavePassedSinceFirstLaunch() {
        let storage = StubRatingPromptStorage(
            data: RatingPromptData(
                appLaunchCount: 20,
                firstLaunchDate: Date().addingTimeInterval(-5 * 24 * 60 * 60), // 5 days ago
                lastPromptedVersion: nil,
                significantEventCount: 10
            )
        )
        let useCase = ShouldShowRatingPromptUseCase(
            storage: storage,
            currentVersion: "1.0.0"
        )
        let configuration = RatingPromptConfiguration(
            minimumDaysSinceFirstLaunch: 7,
            minimumAppLaunches: 10,
            minimumSignificantEvents: 5
        )
        
        let result = useCase(configuration: configuration)
        
        #expect(result == false)
    }
    
    @Test("returns true when app launches insufficient but significant events sufficient")
    func returnsTrueWhenAppLaunchesInsufficientButSignificantEventsSufficient() {
        let storage = StubRatingPromptStorage(
            data: RatingPromptData(
                appLaunchCount: 5,
                firstLaunchDate: Date().addingTimeInterval(-10 * 24 * 60 * 60), // 10 days ago
                lastPromptedVersion: nil,
                significantEventCount: 10
            )
        )
        let useCase = ShouldShowRatingPromptUseCase(
            storage: storage,
            currentVersion: "1.0.0"
        )
        let configuration = RatingPromptConfiguration(
            minimumDaysSinceFirstLaunch: 7,
            minimumAppLaunches: 10,
            minimumSignificantEvents: 5
        )
        
        let result = useCase(configuration: configuration)
        
        #expect(result == true)
    }
    
    @Test("returns true when significant events insufficient but app launches sufficient")
    func returnsTrueWhenSignificantEventsInsufficientButAppLaunchesSufficient() {
        let storage = StubRatingPromptStorage(
            data: RatingPromptData(
                appLaunchCount: 20,
                firstLaunchDate: Date().addingTimeInterval(-10 * 24 * 60 * 60), // 10 days ago
                lastPromptedVersion: nil,
                significantEventCount: 2
            )
        )
        let useCase = ShouldShowRatingPromptUseCase(
            storage: storage,
            currentVersion: "1.0.0"
        )
        let configuration = RatingPromptConfiguration(
            minimumDaysSinceFirstLaunch: 7,
            minimumAppLaunches: 10,
            minimumSignificantEvents: 5
        )
        
        let result = useCase(configuration: configuration)
        
        #expect(result == true)
    }
    
    @Test("returns true when all criteria are met")
    func returnsTrueWhenAllCriteriaAreMet() {
        let storage = StubRatingPromptStorage(
            data: RatingPromptData(
                appLaunchCount: 20,
                firstLaunchDate: Date().addingTimeInterval(-10 * 24 * 60 * 60), // 10 days ago
                lastPromptedVersion: nil,
                significantEventCount: 10
            )
        )
        let useCase = ShouldShowRatingPromptUseCase(
            storage: storage,
            currentVersion: "1.0.0"
        )
        let configuration = RatingPromptConfiguration(
            minimumDaysSinceFirstLaunch: 7,
            minimumAppLaunches: 10,
            minimumSignificantEvents: 5
        )
        
        let result = useCase(configuration: configuration)
        
        #expect(result == true)
    }
    
    @Test("returns true when exactly meeting minimum requirements")
    func returnsTrueWhenExactlyMeetingMinimumRequirements() {
        let storage = StubRatingPromptStorage(
            data: RatingPromptData(
                appLaunchCount: 10,
                firstLaunchDate: Date().addingTimeInterval(-7 * 24 * 60 * 60), // 7 days ago
                lastPromptedVersion: nil,
                significantEventCount: 5
            )
        )
        let useCase = ShouldShowRatingPromptUseCase(
            storage: storage,
            currentVersion: "1.0.0"
        )
        let configuration = RatingPromptConfiguration(
            minimumDaysSinceFirstLaunch: 7,
            minimumAppLaunches: 10,
            minimumSignificantEvents: 5
        )
        
        let result = useCase(configuration: configuration)
        
        #expect(result == true)
    }
    
    @Test("uses default current version when not provided")
    func usesDefaultCurrentVersionWhenNotProvided() {
        let storage = StubRatingPromptStorage(
            data: RatingPromptData(
                appLaunchCount: 20,
                firstLaunchDate: Date().addingTimeInterval(-10 * 24 * 60 * 60), // 10 days ago
                lastPromptedVersion: nil,
                significantEventCount: 10
            )
        )
        let useCase = ShouldShowRatingPromptUseCase(storage: storage)
        let configuration = RatingPromptConfiguration(
            minimumDaysSinceFirstLaunch: 7,
            minimumAppLaunches: 10,
            minimumSignificantEvents: 5
        )
        
        let result = useCase(configuration: configuration)
        
        #expect(result == true)
    }
    
    @Test("returns false when both app launches and significant events are insufficient")
    func returnsFalseWhenBothAppLaunchesAndSignificantEventsAreInsufficient() {
        let storage = StubRatingPromptStorage(
            data: RatingPromptData(
                appLaunchCount: 5,
                firstLaunchDate: Date().addingTimeInterval(-10 * 24 * 60 * 60), // 10 days ago
                lastPromptedVersion: nil,
                significantEventCount: 2
            )
        )
        let useCase = ShouldShowRatingPromptUseCase(
            storage: storage,
            currentVersion: "1.0.0"
        )
        let configuration = RatingPromptConfiguration(
            minimumDaysSinceFirstLaunch: 7,
            minimumAppLaunches: 10,
            minimumSignificantEvents: 5
        )
        
        let result = useCase(configuration: configuration)
        
        #expect(result == false)
    }

    @Test("handles missing first launch date gracefully")
    func handlesMissingFirstLaunchDateGracefully() {
        let storage = StubRatingPromptStorage(
            data: RatingPromptData(
                appLaunchCount: 20,
                firstLaunchDate: nil,
                lastPromptedVersion: nil,
                significantEventCount: 10
            )
        )
        let useCase = ShouldShowRatingPromptUseCase(
            storage: storage,
            currentVersion: "1.0.0"
        )
        let configuration = RatingPromptConfiguration(
            minimumDaysSinceFirstLaunch: 7,
            minimumAppLaunches: 10,
            minimumSignificantEvents: 5
        )
        
        let result = useCase(configuration: configuration)
        
        // Should return false because daysSinceFirstLaunch returns 0 when firstLaunchDate is nil
        #expect(result == false)
    }
}

private final class StubRatingPromptStorage: RatingPromptStorageProtocol, @unchecked Sendable {
    
    private let data: RatingPromptData
    
    init(data: RatingPromptData) {
        self.data = data
    }
    
    func getRatingPromptData() -> RatingPromptData {
        return data
    }
    
    func recordAppLaunch() {}
    
    func recordSignificantEvent() {}
    
    func recordPromptShown(for appVersion: String) {}
    
    func resetCounters() {}
    
    func clearAllData() {}
}
