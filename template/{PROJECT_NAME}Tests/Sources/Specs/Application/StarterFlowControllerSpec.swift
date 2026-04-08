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
            }
        }
    }
}

private actor StarterFlowSessionManagerSpy: StarterFlowSessionManaging {

    private(set) var hasSession = false
    private(set) var didActivateDemoSession = false
    private(set) var didClearSession = false

    func hasActiveSession() -> Bool {
        hasSession
    }

    func activateDemoSession() {
        didActivateDemoSession = true
        hasSession = true
    }

    func clearSession() {
        didClearSession = true
        hasSession = false
    }

    func setHasActiveSession(_ hasSession: Bool) {
        self.hasSession = hasSession
    }
}
