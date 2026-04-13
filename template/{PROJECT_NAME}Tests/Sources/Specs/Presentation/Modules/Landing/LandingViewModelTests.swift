import Testing

import Domain
import FactoryKit
import Foundation
import Model

@testable import {PROJECT_NAME}

@Suite("LandingViewModel", .serialized)
struct LandingViewModelTests {

    @Test("shows the signed-out flow when no active session exists")
    func showsTheSignedOutFlowWhenNoActiveSessionExists() async {
        await Self.withSUT { _, _, viewModel in
            await viewModel.restoreSessionIfNeeded()

            #expect(viewModel.state == .signedOut)
            #expect(viewModel.startupConfigLoadResult == .refreshed)
        }
    }

    @Test("shows the signed-in flow when an active session exists")
    func showsTheSignedInFlowWhenAnActiveSessionExists() async {
        await Self.withSUT { sessionRepository, _, viewModel in
            await sessionRepository.setHasActiveSession(true)

            await viewModel.restoreSessionIfNeeded()

            #expect(viewModel.state == .signedIn)
            #expect(viewModel.startupConfigLoadResult == .refreshed)
        }
    }

    @Test("falls back to local defaults before showing the signed-out flow")
    func fallsBackToLocalDefaultsBeforeShowingTheSignedOutFlow() async {
        await Self.withSUT(startupConfigLoadResult: .usedLocalDefaults) { _, loader, viewModel in
            await viewModel.restoreSessionIfNeeded()

            #expect(viewModel.state == .signedOut)
            #expect(viewModel.startupConfigLoadResult == .usedLocalDefaults)
            #expect(await loader.callCount() == 1)
        }
    }

    @Test("retries restoration after cancellation")
    func retriesRestorationAfterCancellation() async {
        await Self.withSUT(cancelFirstCall: true) { _, loader, viewModel in
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
        await Self.withSUT { _, loader, viewModel in
            await viewModel.restoreSessionIfNeeded()
            await viewModel.restoreSessionIfNeeded()

            #expect(await loader.callCount() == 1)
        }
    }

    @Test("activates a demo session and shows the signed-in flow")
    func activatesADemoSessionAndShowsTheSignedInFlow() async {
        await Self.withSUT { _, _, viewModel in
            await viewModel.continueWithDemoSession()

            #expect(viewModel.state == .signedIn)
        }
    }

    @Test("keeps showing the signed-out flow when activating demo session fails")
    func keepsShowingTheSignedOutFlowWhenActivatingDemoSessionFails() async {
        await Self.withSUT { sessionRepository, _, viewModel in
            await sessionRepository.setShouldFailActivation(true)

            await viewModel.continueWithDemoSession()

            #expect(viewModel.state == .signedOut)
        }
    }

    @Test("clears the session and shows the signed-out flow")
    func clearsTheSessionAndShowsTheSignedOutFlow() async {
        await Self.withSUT { _, _, viewModel in
            await viewModel.continueWithDemoSession()

            await viewModel.signOut()

            #expect(viewModel.state == .signedOut)
        }
    }

    @Test("keeps showing the signed-in flow when clearing session fails")
    func keepsShowingTheSignedInFlowWhenClearingSessionFails() async {
        await Self.withSUT { sessionRepository, _, viewModel in
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
        _ test: @MainActor (SessionRepositoryMock, StartupConfigLoaderMock, LandingViewModel) async -> Void
    ) async {
        Container.shared.reset()

        let sessionRepository = SessionRepositoryMock()
        let startupConfigLoader = StartupConfigLoaderMock(
            result: startupConfigLoadResult,
            shouldCancelFirstCall: cancelFirstCall
        )
        Container.shared.loadStartupConfigUseCase.register { startupConfigLoader }
        Container.shared.sessionRepository.register { sessionRepository }

        let viewModel = LandingViewModel()
        defer {
            Container.shared.reset()
        }

        await test(sessionRepository, startupConfigLoader, viewModel)
    }
}

private actor SessionRepositoryMock: SessionRepositoryProtocol {

    enum SampleError: Error {

        case failed
    }

    private(set) var hasSession = false
    private(set) var shouldFailActivation = false
    private(set) var shouldFailClearSession = false
    private var tokenSet: (any TokenSetProtocol)?

    func hasActiveSession() -> Bool {
        hasSession
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

    func callAsFunction() async throws(CancellationError) -> StartupConfigLoadResult {
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
