import SwiftUI

@MainActor
final class StarterFlowController: ObservableObject {
    enum State: Equatable {
        case loading
        case signedOut
        case signedIn
    }

    @Published private(set) var state: State = .loading

    private let sessionManager: any StarterFlowSessionManaging
    private var hasRestoredSession = false

    init(sessionManager: any StarterFlowSessionManaging = StarterFlowSessionManager()) {
        self.sessionManager = sessionManager
    }

    func restoreSessionIfNeeded() async {
        guard !hasRestoredSession else { return }

        hasRestoredSession = true
        state = await sessionManager.hasActiveSession() ? .signedIn : .signedOut
    }

    func continueWithDemoSession() async {
        do {
            try await sessionManager.activateDemoSession()
            state = .signedIn
        } catch {
            state = .signedOut
        }
    }

    func signOut() async {
        do {
            try await sessionManager.clearSession()
            state = .signedOut
        } catch {
            state = .signedIn
        }
    }
}
