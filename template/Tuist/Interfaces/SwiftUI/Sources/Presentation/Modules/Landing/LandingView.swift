import SwiftUI

@MainActor
struct LandingView: View {

    @StateObject private var viewModel: LandingViewModel

    init() {
        _viewModel = StateObject(wrappedValue: LandingViewModel())
    }

    init(viewModel: LandingViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .signedOut:
                SignOutView(onContinue: continueWithDemoSession)
            case .signedIn:
                HomeView(onSignOut: signOut)
            }
        }
        .task {
            await viewModel.restoreSessionIfNeeded()
        }
    }

    private func continueWithDemoSession() {
        Task {
            await viewModel.continueWithDemoSession()
        }
    }

    private func signOut() {
        Task {
            await viewModel.signOut()
        }
    }
}
