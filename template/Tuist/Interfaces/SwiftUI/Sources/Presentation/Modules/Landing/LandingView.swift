import SwiftUI

@MainActor
struct LandingView: View {

    @StateObject private var viewModel: LandingViewModel
    @Environment(\.openURL) private var openURL

    init(viewModel: LandingViewModel = LandingViewModel()) {
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
            case .forceUpdateRequired:
                ForceUpdateView(onUpdate: openAppStore)
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

    private func openAppStore() {
        openURL(Constants.appStoreURL)
    }
}
