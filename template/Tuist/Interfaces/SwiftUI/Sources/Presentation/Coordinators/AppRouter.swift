import SwiftUI

@MainActor
final class AppRouter: ObservableObject {

    enum PresentationStyle {

        case cover
        case fullScreenCover
    }

    @Published var routes: [AppRoute] = []
    @Published var fullScreenRoutes: [AppRoute] = []
    @Published var coverRoute: AppRoute?
    @Published var fullScreenRoute: AppRoute?

    func push(_ route: AppRoute) {
        routes.append(route)
    }

    func present(_ route: AppRoute, style: PresentationStyle = .fullScreenCover) {
        switch style {
        case .cover:
            fullScreenRoute = nil
            fullScreenRoutes.removeAll()
            coverRoute = route
        case .fullScreenCover:
            coverRoute = nil
            fullScreenRoutes.removeAll()
            fullScreenRoute = route
        }
    }

    func presentFullScreen(_ route: AppRoute) {
        present(route, style: .fullScreenCover)
    }

    func presentCover(_ route: AppRoute) {
        present(route, style: .cover)
    }

    func pop() {
        guard !routes.isEmpty else { return }

        routes.removeLast()
    }

    func popToRoot() {
        routes.removeAll()
    }

    func pushInFullScreen(_ route: AppRoute) {
        fullScreenRoutes.append(route)
    }

    func popFullScreen() {
        guard !fullScreenRoutes.isEmpty else { return }

        fullScreenRoutes.removeLast()
    }

    func popFullScreenToRoot() {
        fullScreenRoutes.removeAll()
    }

    func dismissCover() {
        coverRoute = nil
    }

    func dismissFullScreen() {
        fullScreenRoute = nil
        fullScreenRoutes.removeAll()
    }

    func reset() {
        routes.removeAll()
        coverRoute = nil
        fullScreenRoute = nil
        fullScreenRoutes.removeAll()
    }
}
