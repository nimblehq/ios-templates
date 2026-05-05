import SwiftUI

@MainActor
struct LandingView: View {

    @StateObject private var viewModel: LandingViewModel
    @StateObject private var router: AppRouter
    @Environment(\.openURL) private var openURL

    init() {
        _viewModel = StateObject(wrappedValue: LandingViewModel())
        _router = StateObject(wrappedValue: AppRouter())
    }

    init(viewModel: LandingViewModel, router: AppRouter) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _router = StateObject(wrappedValue: router)
    }

    var body: some View {
        NavigationStack(path: $router.path) {
            Group {
                switch viewModel.state {
                case .loading:
                    Color.clear
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .signedOut:
                    SignOutView(onContinue: continueWithDemoSession)
                case .signedIn:
                    HomeView(
                        onSignOut: signOut,
                        onShowSettings: showSettings,
                        onPresentSettings: presentSettings
                    )
                case .forceUpdateRequired:
                    ForceUpdateView(onUpdate: openAppStore)
                }
            }
            .navigationDestination(for: AppRoute.self, destination: destination)
            .task {
                await viewModel.restoreSessionIfNeeded()
            }
        }
        .fullScreenCover(item: $router.fullScreenRoute, content: fullScreenDestination)
    }

    private func continueWithDemoSession() {
        Task {
            await viewModel.continueWithDemoSession()
        }
    }

    private func signOut() {
        Task {
            await viewModel.signOut()
            router.popToRoot()
            router.dismissFullScreen()
        }
    }

    private func showSettings() {
        router.push(.settings)
    }

    private func presentSettings() {
        router.presentFullScreen(.settings)
    }

    private func openAppStore() {
        openURL(Constants.appStoreURL)
    }

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case .settings:
            SettingsView()
        }
    }

    @ViewBuilder
    private func fullScreenDestination(for route: AppRoute) -> some View {
        NavigationStack {
            destination(for: route)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close", action: router.dismissFullScreen)
                    }
                }
        }
    }
}
