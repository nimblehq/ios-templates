import SwiftUI

@MainActor
struct LandingView: View {

    @StateObject private var viewModel: LandingViewModel = .init()
    @EnvironmentObject private var router: AppRouter
    @Environment(\.openURL) private var openURL

    var body: some View {
        NavigationStack(path: $router.routes) {
            Group {
                switch viewModel.state {
                case .loading:
                    ProgressView("landing.loading.restore_session")
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
        .sheet(item: $router.coverRoute, content: destination)
        .fullScreenCover(item: $router.fullScreenRoute, content: fullScreenDestination)
        .onOpenURL(perform: handleOpenURL)
        .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
            guard let url = userActivity.webpageURL else { return }

            handleOpenURL(url)
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
            router.reset()
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

    private func handleOpenURL(_ url: URL) {
        router.open(url)
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
        NavigationStack(path: $router.fullScreenRoutes) {
            destination(for: route)
                .navigationDestination(for: AppRoute.self, destination: destination)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("common.button.close", action: router.dismissFullScreen)
                    }
                }
        }
    }
}
