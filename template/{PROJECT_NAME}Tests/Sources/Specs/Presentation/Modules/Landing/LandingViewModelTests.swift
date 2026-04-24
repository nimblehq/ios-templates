import Analytics
import Domain
import FactoryKit
import Foundation
import Model
import Testing

@testable import {PROJECT_NAME}

@Suite("LandingViewModel", .serialized)
struct LandingViewModelTests {

    @Test("shows the signed-out flow when no active session exists")
    func showsTheSignedOutFlowWhenNoActiveSessionExists() async {
        await Self.withSUT { _, _, _, viewModel in
            await viewModel.restoreSessionIfNeeded()

            #expect(viewModel.state == .signedOut)
            #expect(viewModel.startupConfigLoadResult == .refreshed)
        }
    }

    @Test("shows the signed-in flow when an active session exists")
    func showsTheSignedInFlowWhenAnActiveSessionExists() async {
        await Self.withSUT { sessionRepository, _, _, viewModel in
            await sessionRepository.setHasActiveSession(true)

            await viewModel.restoreSessionIfNeeded()

            #expect(viewModel.state == .signedIn)
            #expect(viewModel.startupConfigLoadResult == .refreshed)
        }
    }

    @Test("falls back to local defaults before showing the signed-out flow")
    func fallsBackToLocalDefaultsBeforeShowingTheSignedOutFlow() async {
        await Self.withSUT(startupConfigLoadResult: .usedLocalDefaults) { _, loader, _, viewModel in
            await viewModel.restoreSessionIfNeeded()

            #expect(viewModel.state == .signedOut)
            #expect(viewModel.startupConfigLoadResult == .usedLocalDefaults)
            #expect(await loader.callCount() == 1)
        }
    }

    @Test("retries restoration after cancellation")
    func retriesRestorationAfterCancellation() async {
        await Self.withSUT(cancelFirstCall: true) { _, loader, _, viewModel in
            await viewModel.restoreSessionIfNeeded()

            #expect(viewModel.state == .loading)
            #expect(viewModel.startupConfigLoadResult == nil)
            #expect(await loader.callCount() == 1)

            await viewModel.restoreSessionIfNeeded()

            #expect(viewModel.state == .signedOut)
            #expect(viewModel.startupConfigLoadResult == .refreshed)
            #expect(await loader.callCount() == 2)
        }
    }

    @Test("loads startup config only once")
    func loadsStartupConfigOnlyOnce() async {
        await Self.withSUT { _, loader, _, viewModel in
            await viewModel.restoreSessionIfNeeded()
            await viewModel.restoreSessionIfNeeded()

            #expect(await loader.callCount() == 1)
        }
    }

    @Test("shows the force update screen when a force update is required")
    func showsTheForceUpdateScreenWhenAForceUpdateIsRequired() async {
        await Self.withSUT(forceUpdateRequired: true) { _, _, _, viewModel in
            await viewModel.restoreSessionIfNeeded()

            #expect(viewModel.state == .forceUpdateRequired)
            #expect(viewModel.startupConfigLoadResult == .refreshed)
        }
    }

    @Test("skips the session check when a force update is required")
    func skipsTheSessionCheckWhenAForceUpdateIsRequired() async {
        await Self.withSUT(forceUpdateRequired: true) { sessionRepository, _, _, viewModel in
            await viewModel.restoreSessionIfNeeded()

            #expect(viewModel.state == .forceUpdateRequired)
            #expect(await sessionRepository.hasActiveSessionCallCount() == 0)
        }
    }

    @Test("activates a demo session and shows the signed-in flow")
    func activatesADemoSessionAndShowsTheSignedInFlow() async {
        await Self.withSUT { _, _, _, viewModel in
            await viewModel.continueWithDemoSession()

            #expect(viewModel.state == .signedIn)
        }
    }

    @Test("tracks a successful login event when a demo session is activated")
    func tracksASuccessfulLoginEventWhenADemoSessionIsActivated() async {
        await Self.withSUT { _, _, analytics, viewModel in
            await viewModel.continueWithDemoSession()

            #expect(analytics.trackedStructEvents.count == 1)
            #expect(analytics.trackedStructEvents[0].name == "user_login")
            #expect(analytics.trackedStructEvents[0].parameters?["login_method"] as? String == "demo")
            #expect(analytics.trackedStructEvents[0].parameters?["is_successful"] as? Bool == true)
        }
    }

    @Test("keeps showing the signed-out flow when activating demo session fails")
    func keepsShowingTheSignedOutFlowWhenActivatingDemoSessionFails() async {
        await Self.withSUT { sessionRepository, _, _, viewModel in
            await sessionRepository.setShouldFailActivation(true)

            await viewModel.continueWithDemoSession()

            #expect(viewModel.state == .signedOut)
        }
    }

    @Test("tracks a failed login event when a demo session activation fails")
    func tracksAFailedLoginEventWhenADemoSessionActivationFails() async {
        await Self.withSUT { sessionRepository, _, analytics, viewModel in
            await sessionRepository.setShouldFailActivation(true)

            await viewModel.continueWithDemoSession()

            #expect(analytics.trackedStructEvents.count == 1)
            #expect(analytics.trackedStructEvents[0].name == "user_login")
            #expect(analytics.trackedStructEvents[0].parameters?["login_method"] as? String == "demo")
            #expect(analytics.trackedStructEvents[0].parameters?["is_successful"] as? Bool == false)
        }
    }

    @Test("clears the session and shows the signed-out flow")
    func clearsTheSessionAndShowsTheSignedOutFlow() async {
        await Self.withSUT { _, _, _, viewModel in
            await viewModel.continueWithDemoSession()

            await viewModel.signOut()

            #expect(viewModel.state == .signedOut)
        }
    }

    @Test("keeps showing the signed-in flow when clearing session fails")
    func keepsShowingTheSignedInFlowWhenClearingSessionFails() async {
        await Self.withSUT { sessionRepository, _, _, viewModel in
            await viewModel.continueWithDemoSession()
            await sessionRepository.setShouldFailClearSession(true)

            await viewModel.signOut()

            #expect(viewModel.state == .signedIn)
        }
    }

    @MainActor
    private static func withSUT(
        startupConfigLoadResult: StartupConfigLoadResult = .refreshed,
        cancelFirstCall: Bool = false,
        forceUpdateRequired: Bool = false,
        _ test: @MainActor (SessionRepositoryMock, StartupConfigLoaderMock, AnalyticsProtocolMock, LandingViewModel) async -> Void
    ) async {
        Container.shared.reset()

        let sessionRepository = SessionRepositoryMock()
        let startupConfigLoader = StartupConfigLoaderMock(
            result: startupConfigLoadResult,
            shouldCancelFirstCall: cancelFirstCall
        )
        let analytics = AnalyticsProtocolMock()
        Container.shared.loadStartupConfigUseCase.register { startupConfigLoader }
        Container.shared.sessionRepository.register { sessionRepository }
        Container.shared.analytics.register { analytics }

        let checkForceUpdateUseCase = CheckForceUpdateUseCaseMock(shouldForceUpdate: forceUpdateRequired)
        Container.shared.checkForceUpdateUseCase.register { checkForceUpdateUseCase }

        let viewModel = LandingViewModel()
        defer {
            Container.shared.reset()
        }

        await test(sessionRepository, startupConfigLoader, analytics, viewModel)
    }
}

private final class AnalyticsProtocolMock: AnalyticsProtocol, @unchecked Sendable {

    private(set) var trackedStructEvents: [AnalyticsEvent] = []

    func configure(trackers: [AnalyticsTracker], additionalParameters: [String: Any]?) {}

    func addTracker(_ tracker: AnalyticsTracker, additionalParameters: [String: Any]?) {}

    func trackEvent(name: String, parameters: [String: Any]?) {}

    func trackEvent(name: String, parameters: [String: Any]?, on trackerTypes: [AnalyticsTrackerType]) {}

    func trackEvent(_ event: AnalyticsEvent) {
        trackedStructEvents.append(event)
    }

    func trackEvent(_ event: AnalyticsEvent, on trackerTypes: [AnalyticsTrackerType]) {
        trackedStructEvents.append(event)
    }

    func trackScreen(name: String, screenClass: String?) {}

    func trackScreen(name: String, screenClass: String?, on trackerTypes: [AnalyticsTrackerType]) {}

    func setUserProperty(key: String, value: String) {}

    func setUserProperty(key: String, value: String, on trackerTypes: [AnalyticsTrackerType]) {}

    func setUserId(_ userId: String?) {}

    func setUserId(_ userId: String?, on trackerTypes: [AnalyticsTrackerType]) {}

    func tracker(for type: AnalyticsTrackerType) -> AnalyticsTracker? { nil }
}

private actor SessionRepositoryMock: SessionRepositoryProtocol {

    enum SampleError: Error {

        case failed
    }

    private(set) var hasSession = false
    private(set) var hasActiveSessionCallCountValue = 0
    private(set) var shouldFailActivation = false
    private(set) var shouldFailClearSession = false
    private var tokenSet: (any TokenSetProtocol)?

    func hasActiveSession() -> Bool {
        hasActiveSessionCallCountValue += 1
        return hasSession
    }

    func hasActiveSessionCallCount() -> Int {
        hasActiveSessionCallCountValue
    }

    func currentTokenSet() -> (any TokenSetProtocol)? {
        tokenSet
    }

    func save(tokenSet: any TokenSetProtocol) throws {
        if shouldFailActivation {
            throw SampleError.failed
        }
        self.tokenSet = tokenSet
        hasSession = true
    }

    func clearSession() throws {
        if shouldFailClearSession {
            throw SampleError.failed
        }
        tokenSet = nil
        hasSession = false
    }

    func setHasActiveSession(_ hasSession: Bool) {
        self.hasSession = hasSession
    }

    func setShouldFailActivation(_ shouldFailActivation: Bool) {
        self.shouldFailActivation = shouldFailActivation
    }

    func setShouldFailClearSession(_ shouldFailClearSession: Bool) {
        self.shouldFailClearSession = shouldFailClearSession
    }
}

private actor StartupConfigLoaderMock: LoadStartupConfigUseCaseProtocol {

    private let result: StartupConfigLoadResult
    private let shouldCancelFirstCall: Bool
    private var didCancelFirstCall = false
    private var callCountValue = 0

    init(result: StartupConfigLoadResult, shouldCancelFirstCall: Bool = false) {
        self.result = result
        self.shouldCancelFirstCall = shouldCancelFirstCall
    }

    func callAsFunction() async throws -> StartupConfigLoadResult {
        callCountValue += 1

        if shouldCancelFirstCall, !didCancelFirstCall {
            didCancelFirstCall = true
            throw CancellationError()
        }

        return result
    }

    func callCount() -> Int {
        callCountValue
    }
}
