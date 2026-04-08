import Nimble
import Quick

@testable import {PROJECT_NAME}

final class StarterFlowControllerSpec: AsyncSpec {

    override class func spec() {

        describe("a StarterFlowController") {

            var sessionManager: StarterFlowSessionManagerSpy!
            var controller: StarterFlowController!

            beforeEach {
                sessionManager = StarterFlowSessionManagerSpy()
                let currentSessionManager = sessionManager!
                controller = await MainActor.run {
                    StarterFlowController(sessionManager: currentSessionManager)
                }
            }

            describe("its restoreSessionIfNeeded") {

                context("when no active session exists") {

                    it("shows the signed-out flow") {
                        let currentController = controller!
                        await controller.restoreSessionIfNeeded()

                        let state = await MainActor.run { currentController.state }
                        expect(state) == .signedOut
                    }
                }

                context("when an active session exists") {

                    beforeEach {
                        await sessionManager.setHasActiveSession(true)
                    }

                    it("shows the signed-in flow") {
                        let currentController = controller!
                        await controller.restoreSessionIfNeeded()

                        let state = await MainActor.run { currentController.state }
                        expect(state) == .signedIn
                    }
                }
            }

            describe("its continueWithDemoSession") {

                it("activates a demo session and shows the signed-in flow") {
                    let currentController = controller!
                    await controller.continueWithDemoSession()

                    let didActivateDemoSession = await sessionManager.didActivateDemoSession
                    let state = await MainActor.run { currentController.state }
                    expect(didActivateDemoSession) == true
                    expect(state) == .signedIn
                }

                context("when activating demo session fails") {

                    beforeEach {
                        await sessionManager.setShouldFailActivation(true)
                    }

                    it("keeps showing the signed-out flow") {
                        let currentController = controller!
                        await controller.continueWithDemoSession()

                        let didActivateDemoSession = await sessionManager.didActivateDemoSession
                        let state = await MainActor.run { currentController.state }
                        expect(didActivateDemoSession) == true
                        expect(state) == .signedOut
                    }
                }
            }

            describe("its signOut") {

                beforeEach {
                    await controller.continueWithDemoSession()
                }

                it("clears the session and shows the signed-out flow") {
                    let currentController = controller!
                    await controller.signOut()

                    let didClearSession = await sessionManager.didClearSession
                    let state = await MainActor.run { currentController.state }
                    expect(didClearSession) == true
                    expect(state) == .signedOut
                }

                context("when clearing session fails") {

                    beforeEach {
                        await sessionManager.setShouldFailClearSession(true)
                    }

                    it("keeps showing the signed-in flow") {
                        let currentController = controller!
                        await controller.signOut()

                        let didClearSession = await sessionManager.didClearSession
                        let state = await MainActor.run { currentController.state }
                        expect(didClearSession) == true
                        expect(state) == .signedIn
                    }
                }
            }
        }
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
