import SwiftUI

struct AppRootView: View {

    @StateObject private var controller: StarterFlowController

    init() {
        _controller = StateObject(wrappedValue: StarterFlowController())
    }

    init(controller: StarterFlowController) {
        _controller = StateObject(wrappedValue: controller)
    }

    var body: some View {
        Group {
            switch controller.state {
            case .loading:
                ProgressView("Restoring session...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .signedOut:
                SignOutView {
                    Task {
                        await controller.continueWithDemoSession()
                    }
                }
            case .signedIn:
                HomeView {
                    Task {
                        await controller.signOut()
                    }
                }
            }
        }
        .task {
            await controller.restoreSessionIfNeeded()
        }
    }
}
