import Testing

@testable import {PROJECT_NAME}

@Suite("StarterFlowController")
struct StarterFlowControllerTests {

    @Test("shows the signed-out flow when no active session exists")
    @MainActor
    func restoreSessionIfNeededShowsTheSignedOutFlowWhenNoActiveSessionExists() async {
        let (_, controller) = makeSUT()

        await controller.restoreSessionIfNeeded()

        #expect(controller.state == .signedOut)
    }

    @Test("shows the signed-in flow when an active session exists")
    @MainActor
    func restoreSessionIfNeededShowsTheSignedInFlowWhenAnActiveSessionExists() async {
        let (sessionManager, controller) = makeSUT()
        await sessionManager.setHasActiveSession(true)

        await controller.restoreSessionIfNeeded()

        #expect(controller.state == .signedIn)
    }

    @Test("activates a demo session and shows the signed-in flow")
    @MainActor
    func continueWithDemoSessionActivatesADemoSessionAndShowsTheSignedInFlow() async {
        let (sessionManager, controller) = makeSUT()

        await controller.continueWithDemoSession()

        let didActivateDemoSession = await sessionManager.didActivateDemoSession

        #expect(didActivateDemoSession == true)
        #expect(controller.state == .signedIn)
    }

    @Test("keeps showing the signed-out flow when activating demo session fails")
    @MainActor
    func continueWithDemoSessionKeepsShowingTheSignedOutFlowWhenActivationFails() async {
        let (sessionManager, controller) = makeSUT()
        await sessionManager.setShouldFailActivation(true)

        await controller.continueWithDemoSession()

        let didActivateDemoSession = await sessionManager.didActivateDemoSession

        #expect(didActivateDemoSession == true)
        #expect(controller.state == .signedOut)
    }

    @Test("clears the session and shows the signed-out flow")
    @MainActor
    func signOutClearsTheSessionAndShowsTheSignedOutFlow() async {
        let (sessionManager, controller) = makeSUT()
        await controller.continueWithDemoSession()

        await controller.signOut()

        let didClearSession = await sessionManager.didClearSession

        #expect(didClearSession == true)
        #expect(controller.state == .signedOut)
    }

    @Test("keeps showing the signed-in flow when clearing session fails")
    @MainActor
    func signOutKeepsShowingTheSignedInFlowWhenClearingSessionFails() async {
        let (sessionManager, controller) = makeSUT()
        await controller.continueWithDemoSession()
        await sessionManager.setShouldFailClearSession(true)

        await controller.signOut()

        let didClearSession = await sessionManager.didClearSession

        #expect(didClearSession == true)
        #expect(controller.state == .signedIn)
    }

    @MainActor
    private func makeSUT() -> (sessionManager: StarterFlowSessionManagerSpy, controller: StarterFlowController) {
        let sessionManager = StarterFlowSessionManagerSpy()
        let controller = StarterFlowController(sessionManager: sessionManager)
        return (sessionManager, controller)
    }
}

private actor StarterFlowSessionManagerSpy: StarterFlowSessionManaging {

    enum SampleError: Error {

        case failed
    }

    private(set) var hasSession = false
    private(set) var didActivateDemoSession = false
    private(set) var didClearSession = false
    private(set) var shouldFailActivation = false
    private(set) var shouldFailClearSession = false

    func hasActiveSession() -> Bool {
        hasSession
    }

    func activateDemoSession() throws {
        didActivateDemoSession = true
        if shouldFailActivation {
            throw SampleError.failed
        }
        hasSession = true
    }

    func clearSession() throws {
        didClearSession = true
        if shouldFailClearSession {
            throw SampleError.failed
        }
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
