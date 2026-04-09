import Domain
import Foundation
import Model
import Testing

@testable import {PROJECT_NAME}

@Suite("LandingViewModel")
struct LandingViewModelTests {

    @Test("shows the signed-out flow when no active session exists")
    @MainActor
    func restoreSessionIfNeededShowsTheSignedOutFlowWhenNoActiveSessionExists() async {
        let (_, viewModel) = makeSUT()

        await viewModel.restoreSessionIfNeeded()

        #expect(viewModel.state == .signedOut)
    }

    @Test("shows the signed-in flow when an active session exists")
    @MainActor
    func restoreSessionIfNeededShowsTheSignedInFlowWhenAnActiveSessionExists() async {
        let (sessionRepository, viewModel) = makeSUT()
        await sessionRepository.setHasActiveSession(true)

        await viewModel.restoreSessionIfNeeded()

        #expect(viewModel.state == .signedIn)
    }

    @Test("activates a demo session and shows the signed-in flow")
    @MainActor
    func continueWithDemoSessionActivatesADemoSessionAndShowsTheSignedInFlow() async {
        let (sessionRepository, viewModel) = makeSUT()

        await viewModel.continueWithDemoSession()

        let didActivateDemoSession = await sessionRepository.didActivateDemoSession

        #expect(didActivateDemoSession == true)
        #expect(viewModel.state == .signedIn)
    }

    @Test("keeps showing the signed-out flow when activating demo session fails")
    @MainActor
    func continueWithDemoSessionKeepsShowingTheSignedOutFlowWhenActivationFails() async {
        let (sessionRepository, viewModel) = makeSUT()
        await sessionRepository.setShouldFailActivation(true)

        await viewModel.continueWithDemoSession()

        let didActivateDemoSession = await sessionRepository.didActivateDemoSession

        #expect(didActivateDemoSession == true)
        #expect(viewModel.state == .signedOut)
    }

    @Test("clears the session and shows the signed-out flow")
    @MainActor
    func signOutClearsTheSessionAndShowsTheSignedOutFlow() async {
        let (sessionRepository, viewModel) = makeSUT()
        await viewModel.continueWithDemoSession()

        await viewModel.signOut()

        let didClearSession = await sessionRepository.didClearSession

        #expect(didClearSession == true)
        #expect(viewModel.state == .signedOut)
    }

    @Test("keeps showing the signed-in flow when clearing session fails")
    @MainActor
    func signOutKeepsShowingTheSignedInFlowWhenClearingSessionFails() async {
        let (sessionRepository, viewModel) = makeSUT()
        await viewModel.continueWithDemoSession()
        await sessionRepository.setShouldFailClearSession(true)

        await viewModel.signOut()

        let didClearSession = await sessionRepository.didClearSession

        #expect(didClearSession == true)
        #expect(viewModel.state == .signedIn)
    }

    @MainActor
    private func makeSUT() -> (sessionRepository: SessionRepositoryMock, viewModel: LandingViewModel) {
        let sessionRepository = SessionRepositoryMock()
        let viewModel = LandingViewModel(sessionRepository: sessionRepository)
        return (sessionRepository, viewModel)
    }
}

private actor SessionRepositoryMock: SessionRepositoryProtocol {

    enum SampleError: Error {

        case failed
    }

    private(set) var hasSession = false
    private(set) var didActivateDemoSession = false
    private(set) var didClearSession = false
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
        didActivateDemoSession = true
        if shouldFailActivation {
            throw SampleError.failed
        }
        self.tokenSet = tokenSet
        hasSession = true
    }

    func clearSession() throws {
        didClearSession = true
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
