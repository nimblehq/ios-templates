import Foundation
import Testing

@testable import Domain

@Suite("RequestRatingPromptUseCase")
@MainActor
struct RequestRatingPromptUseCaseTests {

    @Test("returns false when should not show rating prompt")
    func returnsFalseWhenShouldNotShowRatingPrompt() async {
        let repository = SpyRatingPromptRepository()
        let shouldShowUseCase = StubShouldShowRatingPromptUseCase(shouldShow: false)
        let presenter = SpyRatingPromptPresenter()
        let useCase = RequestRatingPromptUseCase(
            repository: repository,
            shouldShowRatingPromptUseCase: shouldShowUseCase,
            presenter: presenter,
            currentVersion: { "1.0.0" }
        )
        let configuration = RatingPromptConfiguration()

        let result = await useCase(configuration: configuration)

        #expect(result == false)
        #expect(presenter.showCallCount == 0)
        #expect(repository.recordPromptShownCallCount == 0)
        #expect(repository.resetCountersCallCount == 0)
    }

    @Test("returns true and shows prompt when eligible")
    func returnsTrueAndShowsPromptWhenEligible() async {
        let repository = SpyRatingPromptRepository()
        let shouldShowUseCase = StubShouldShowRatingPromptUseCase(shouldShow: true)
        let presenter = SpyRatingPromptPresenter()
        let useCase = RequestRatingPromptUseCase(
            repository: repository,
            shouldShowRatingPromptUseCase: shouldShowUseCase,
            presenter: presenter,
            currentVersion: { "1.0.0" }
        )
        let configuration = RatingPromptConfiguration()

        let result = await useCase(configuration: configuration)

        #expect(result == true)
        #expect(presenter.showCallCount == 1)
        #expect(repository.recordPromptShownCallCount == 1)
        #expect(repository.recordPromptShownVersion == "1.0.0")
    }

    @Test("resets counters when resetCounterAfterPrompt is true")
    func resetsCountersWhenResetCounterAfterPromptIsTrue() async {
        let repository = SpyRatingPromptRepository()
        let shouldShowUseCase = StubShouldShowRatingPromptUseCase(shouldShow: true)
        let presenter = SpyRatingPromptPresenter()
        let useCase = RequestRatingPromptUseCase(
            repository: repository,
            shouldShowRatingPromptUseCase: shouldShowUseCase,
            presenter: presenter,
            currentVersion: { "1.0.0" }
        )
        let configuration = RatingPromptConfiguration(resetCounterAfterPrompt: true)

        let result = await useCase(configuration: configuration)

        #expect(result == true)
        #expect(repository.resetCountersCallCount == 1)
    }

    @Test("does not reset counters when resetCounterAfterPrompt is false")
    func doesNotResetCountersWhenResetCounterAfterPromptIsFalse() async {
        let repository = SpyRatingPromptRepository()
        let shouldShowUseCase = StubShouldShowRatingPromptUseCase(shouldShow: true)
        let presenter = SpyRatingPromptPresenter()
        let useCase = RequestRatingPromptUseCase(
            repository: repository,
            shouldShowRatingPromptUseCase: shouldShowUseCase,
            presenter: presenter,
            currentVersion: { "1.0.0" }
        )
        let configuration = RatingPromptConfiguration(resetCounterAfterPrompt: false)

        let result = await useCase(configuration: configuration)

        #expect(result == true)
        #expect(repository.resetCountersCallCount == 0)
    }

    @Test("uses current version from closure")
    func usesCurrentVersionFromClosure() async {
        let repository = SpyRatingPromptRepository()
        let shouldShowUseCase = StubShouldShowRatingPromptUseCase(shouldShow: true)
        let presenter = SpyRatingPromptPresenter()
        let useCase = RequestRatingPromptUseCase(
            repository: repository,
            shouldShowRatingPromptUseCase: shouldShowUseCase,
            presenter: presenter,
            currentVersion: { "2.1.0" }
        )
        let configuration = RatingPromptConfiguration()

        let result = await useCase(configuration: configuration)

        #expect(result == true)
        #expect(repository.recordPromptShownVersion == "2.1.0")
    }

    @Test("uses default current version when not provided")
    func usesDefaultCurrentVersionWhenNotProvided() async {
        let repository = SpyRatingPromptRepository()
        let shouldShowUseCase = StubShouldShowRatingPromptUseCase(shouldShow: true)
        let presenter = SpyRatingPromptPresenter()
        let useCase = RequestRatingPromptUseCase(
            repository: repository,
            shouldShowRatingPromptUseCase: shouldShowUseCase,
            presenter: presenter
        )
        let configuration = RatingPromptConfiguration()

        let result = await useCase(configuration: configuration)

        #expect(result == true)
        #expect(repository.recordPromptShownVersion != nil)
        #expect(repository.recordPromptShownVersion?.isEmpty == false)
    }

    @Test("returns false when presenter fails to show prompt")
    func returnsFalseWhenPresenterFailsToShowPrompt() async {
        let repository = SpyRatingPromptRepository()
        let shouldShowUseCase = StubShouldShowRatingPromptUseCase(shouldShow: true)
        let presenter = SpyRatingPromptPresenter(shouldReturnTrue: false)
        let useCase = RequestRatingPromptUseCase(
            repository: repository,
            shouldShowRatingPromptUseCase: shouldShowUseCase,
            presenter: presenter,
            currentVersion: { "1.0.0" }
        )
        let configuration = RatingPromptConfiguration()

        let result = await useCase(configuration: configuration)

        #expect(result == false)
        #expect(presenter.showCallCount == 1)
        #expect(repository.recordPromptShownCallCount == 0) // Should not record when presenter fails
        #expect(repository.resetCountersCallCount == 0) // Should not reset when presenter fails
    }

    @Test("passes configuration to shouldShowRatingPromptUseCase")
    func passesConfigurationToShouldShowRatingPromptUseCase() async {
        let repository = SpyRatingPromptRepository()
        let shouldShowUseCase = StubShouldShowRatingPromptUseCase(shouldShow: true)
        let presenter = SpyRatingPromptPresenter()
        let useCase = RequestRatingPromptUseCase(
            repository: repository,
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

private final class SpyRatingPromptRepository: RatingPromptRepositoryProtocol, @unchecked Sendable {

    private(set) var recordPromptShownCallCount = 0
    private(set) var recordPromptShownVersion: String?
    private(set) var resetCountersCallCount = 0

    func getRatingPromptData() async -> RatingPromptData {
        RatingPromptData()
    }

    func recordAppLaunch() async {}

    func recordSignificantEvent() async {}

    func recordPromptShown(for appVersion: String) async {
        recordPromptShownCallCount += 1
        recordPromptShownVersion = appVersion
    }

    func resetCounters() async {
        resetCountersCallCount += 1
    }

    func clearAllData() async {}
}

private final class StubShouldShowRatingPromptUseCase: ShouldShowRatingPromptUseCaseProtocol, @unchecked Sendable {

    private let shouldShow: Bool
    private(set) var receivedConfiguration: RatingPromptConfiguration?

    init(shouldShow: Bool) {
        self.shouldShow = shouldShow
    }

    func callAsFunction(configuration: RatingPromptConfiguration) async -> Bool {
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
