import Foundation
import Testing

@testable import Domain

@Suite("RequestRatingPromptUseCase")
struct RequestRatingPromptUseCaseTests {

    @Test("returns false when should not show rating prompt")
    func returnsFalseWhenShouldNotShowRatingPrompt() async {
        let storage = SpyRatingPromptStorage()
        let shouldShowUseCase = StubShouldShowRatingPromptUseCase(shouldShow: false)
        let presenter = SpyRatingPromptPresenter()
        let useCase = RequestRatingPromptUseCase(
            storage: storage,
            shouldShowRatingPromptUseCase: shouldShowUseCase,
            presenter: presenter,
            currentVersion: { "1.0.0" }
        )
        let configuration = RatingPromptConfiguration()
        
        let result = await useCase(configuration: configuration)
        
        #expect(result == false)
        #expect(presenter.showCallCount == 0)
        #expect(storage.recordPromptShownCallCount == 0)
        #expect(storage.resetCountersCallCount == 0)
    }
    
    @Test("returns true and shows prompt when eligible")
    func returnsTrueAndShowsPromptWhenEligible() async {
        let storage = SpyRatingPromptStorage()
        let shouldShowUseCase = StubShouldShowRatingPromptUseCase(shouldShow: true)
        let presenter = SpyRatingPromptPresenter()
        let useCase = RequestRatingPromptUseCase(
            storage: storage,
            shouldShowRatingPromptUseCase: shouldShowUseCase,
            presenter: presenter,
            currentVersion: { "1.0.0" }
        )
        let configuration = RatingPromptConfiguration()
        
        let result = await useCase(configuration: configuration)
        
        #expect(result == true)
        #expect(presenter.showCallCount == 1)
        #expect(storage.recordPromptShownCallCount == 1)
        #expect(storage.recordPromptShownVersion == "1.0.0")
    }
    
    @Test("resets counters when resetCounterAfterPrompt is true")
    func resetsCountersWhenResetCounterAfterPromptIsTrue() async {
        let storage = SpyRatingPromptStorage()
        let shouldShowUseCase = StubShouldShowRatingPromptUseCase(shouldShow: true)
        let presenter = SpyRatingPromptPresenter()
        let useCase = RequestRatingPromptUseCase(
            storage: storage,
            shouldShowRatingPromptUseCase: shouldShowUseCase,
            presenter: presenter,
            currentVersion: { "1.0.0" }
        )
        let configuration = RatingPromptConfiguration(resetCounterAfterPrompt: true)
        
        let result = await useCase(configuration: configuration)
        
        #expect(result == true)
        #expect(storage.resetCountersCallCount == 1)
    }
    
    @Test("does not reset counters when resetCounterAfterPrompt is false")
    func doesNotResetCountersWhenResetCounterAfterPromptIsFalse() async {
        let storage = SpyRatingPromptStorage()
        let shouldShowUseCase = StubShouldShowRatingPromptUseCase(shouldShow: true)
        let presenter = SpyRatingPromptPresenter()
        let useCase = RequestRatingPromptUseCase(
            storage: storage,
            shouldShowRatingPromptUseCase: shouldShowUseCase,
            presenter: presenter,
            currentVersion: { "1.0.0" }
        )
        let configuration = RatingPromptConfiguration(resetCounterAfterPrompt: false)
        
        let result = await useCase(configuration: configuration)
        
        #expect(result == true)
        #expect(storage.resetCountersCallCount == 0)
    }
    
    @Test("uses current version from closure")
    func usesCurrentVersionFromClosure() async {
        let storage = SpyRatingPromptStorage()
        let shouldShowUseCase = StubShouldShowRatingPromptUseCase(shouldShow: true)
        let presenter = SpyRatingPromptPresenter()
        let useCase = RequestRatingPromptUseCase(
            storage: storage,
            shouldShowRatingPromptUseCase: shouldShowUseCase,
            presenter: presenter,
            currentVersion: { "2.1.0" }
        )
        let configuration = RatingPromptConfiguration()
        
        let result = await useCase(configuration: configuration)
        
        #expect(result == true)
        #expect(storage.recordPromptShownVersion == "2.1.0")
    }
    
    @Test("uses default current version when not provided")
    func usesDefaultCurrentVersionWhenNotProvided() async {
        let storage = SpyRatingPromptStorage()
        let shouldShowUseCase = StubShouldShowRatingPromptUseCase(shouldShow: true)
        let presenter = SpyRatingPromptPresenter()
        let useCase = RequestRatingPromptUseCase(
            storage: storage,
            shouldShowRatingPromptUseCase: shouldShowUseCase,
            presenter: presenter
        )
        let configuration = RatingPromptConfiguration()
        
        let result = await useCase(configuration: configuration)
        
        #expect(result == true)
        #expect(storage.recordPromptShownVersion != nil)
        #expect(storage.recordPromptShownVersion?.isEmpty == false)
    }
    
    @Test("returns false when presenter fails to show prompt")
    func returnsFalseWhenPresenterFailsToShowPrompt() async {
        let storage = SpyRatingPromptStorage()
        let shouldShowUseCase = StubShouldShowRatingPromptUseCase(shouldShow: true)
        let presenter = SpyRatingPromptPresenter(shouldReturnTrue: false)
        let useCase = RequestRatingPromptUseCase(
            storage: storage,
            shouldShowRatingPromptUseCase: shouldShowUseCase,
            presenter: presenter,
            currentVersion: { "1.0.0" }
        )
        let configuration = RatingPromptConfiguration()
        
        let result = await useCase(configuration: configuration)
        
        #expect(result == false)
        #expect(presenter.showCallCount == 1)
        #expect(storage.recordPromptShownCallCount == 0) // Should not record when presenter fails
        #expect(storage.resetCountersCallCount == 0) // Should not reset when presenter fails
    }
    
    @Test("passes configuration to shouldShowRatingPromptUseCase")
    func passesConfigurationToShouldShowRatingPromptUseCase() async {
        let storage = SpyRatingPromptStorage()
        let shouldShowUseCase = StubShouldShowRatingPromptUseCase(shouldShow: true)
        let presenter = SpyRatingPromptPresenter()
        let useCase = RequestRatingPromptUseCase(
            storage: storage,
            shouldShowRatingPromptUseCase: shouldShowUseCase,
            presenter: presenter,
            currentVersion: { "1.0.0" }
        )
        let configuration = RatingPromptConfiguration(
            minimumDaysSinceFirstLaunch: 14,
            minimumAppLaunches: 20,
            minimumSignificantEvents: 10
        )
        
        let result = await useCase(configuration: configuration)
        
        #expect(result == true)
        #expect(shouldShowUseCase.receivedConfiguration?.minimumDaysSinceFirstLaunch == 14)
        #expect(shouldShowUseCase.receivedConfiguration?.minimumAppLaunches == 20)
        #expect(shouldShowUseCase.receivedConfiguration?.minimumSignificantEvents == 10)
    }
}

// MARK: - Test Doubles

private final class SpyRatingPromptStorage: RatingPromptStorageProtocol, @unchecked Sendable {
    
    private(set) var recordPromptShownCallCount = 0
    private(set) var recordPromptShownVersion: String?
    private(set) var resetCountersCallCount = 0
    
    func getRatingPromptData() -> RatingPromptData {
        return RatingPromptData()
    }
    
    func recordAppLaunch() {}
    
    func recordSignificantEvent() {}
    
    func recordPromptShown(for appVersion: String) {
        recordPromptShownCallCount += 1
        recordPromptShownVersion = appVersion
    }
    
    func resetCounters() {
        resetCountersCallCount += 1
    }
    
    func clearAllData() {}
}

private final class StubShouldShowRatingPromptUseCase: ShouldShowRatingPromptUseCaseProtocol, @unchecked Sendable {
    
    private let shouldShow: Bool
    private(set) var receivedConfiguration: RatingPromptConfiguration?
    
    init(shouldShow: Bool) {
        self.shouldShow = shouldShow
    }
    
    func callAsFunction(configuration: RatingPromptConfiguration) -> Bool {
        receivedConfiguration = configuration
        return shouldShow
    }
}

private final class SpyRatingPromptPresenter: RatingPromptPresenterProtocol, @unchecked Sendable {
    
    private(set) var showCallCount = 0
    private let shouldReturnTrue: Bool
    
    init(shouldReturnTrue: Bool = true) {
        self.shouldReturnTrue = shouldReturnTrue
    }
    
    func show() async -> Bool {
        showCallCount += 1
        return shouldReturnTrue
    }
}
