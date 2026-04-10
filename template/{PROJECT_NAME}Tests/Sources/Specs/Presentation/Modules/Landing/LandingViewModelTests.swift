import Domain
import FactoryKit
import Foundation
import Model
import Testing

@testable import {PROJECT_NAME}

@Suite("LandingViewModel")
struct LandingViewModelTests {

    @Test("shows the signed-out flow when no active session exists")
    @MainActor
    func restoreSessionIfNeededShowsTheSignedOutFlowWhenNoActiveSessionExists() async {
        await withSUT { _, viewModel in
            await viewModel.restoreSessionIfNeeded()

            #expect(viewModel.state == .signedOut)
        }
    }

    @Test("shows the signed-in flow when an active session exists")
    @MainActor
    func restoreSessionIfNeededShowsTheSignedInFlowWhenAnActiveSessionExists() async {
        await withSUT { sessionRepository, viewModel in
            await sessionRepository.setHasActiveSession(true)

            await viewModel.restoreSessionIfNeeded()

            #expect(viewModel.state == .signedIn)
        }
    }

    @Test("activates a demo session and shows the signed-in flow")
    @MainActor
    func continueWithDemoSessionActivatesADemoSessionAndShowsTheSignedInFlow() async {
        await withSUT { _, viewModel in
            await viewModel.continueWithDemoSession()

            #expect(viewModel.state == .signedIn)
        }
    }

    @Test("keeps showing the signed-out flow when activating demo session fails")
    @MainActor
    func continueWithDemoSessionKeepsShowingTheSignedOutFlowWhenActivationFails() async {
        await withSUT { sessionRepository, viewModel in
            await sessionRepository.setShouldFailActivation(true)

            await viewModel.continueWithDemoSession()

            #expect(viewModel.state == .signedOut)
        }
    }

    @Test("clears the session and shows the signed-out flow")
    @MainActor
    func signOutClearsTheSessionAndShowsTheSignedOutFlow() async {
        await withSUT { _, viewModel in
            await viewModel.continueWithDemoSession()

            await viewModel.signOut()

            #expect(viewModel.state == .signedOut)
        }
    }

    @Test("keeps showing the signed-in flow when clearing session fails")
    @MainActor
    func signOutKeepsShowingTheSignedInFlowWhenClearingSessionFails() async {
        await withSUT { sessionRepository, viewModel in
            await viewModel.continueWithDemoSession()
            await sessionRepository.setShouldFailClearSession(true)

            await viewModel.signOut()

            #expect(viewModel.state == .signedIn)
        }
    }

    @MainActor
    private func withSUT(
        _ test: @MainActor (SessionRepositoryMock, LandingViewModel) async -> Void
    ) async {
        Container.shared.reset()

        let sessionRepository = SessionRepositoryMock()
        Container.shared.sessionRepository.register { sessionRepository }

        let viewModel = LandingViewModel()
        defer {
            Container.shared.reset()
        }

        await test(sessionRepository, viewModel)
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
