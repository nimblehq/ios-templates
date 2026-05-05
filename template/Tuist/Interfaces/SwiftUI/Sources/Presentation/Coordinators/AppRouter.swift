import SwiftUI

@MainActor
final class AppRouter: ObservableObject {

    enum PresentationStyle {

        case cover
        case fullScreenCover
    }

    @Published var routes: [AppRoute] = []
    @Published var coverRoute: AppRoute?
    @Published var fullScreenRoute: AppRoute?

    func push(_ route: AppRoute) {
        routes.append(route)
    }

    func present(_ route: AppRoute, style: PresentationStyle = .fullScreenCover) {
        switch style {
        case .cover:
            coverRoute = route
        case .fullScreenCover:
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

    func dismissCover() {
        coverRoute = nil
    }

    func dismissFullScreen() {
        fullScreenRoute = nil
    }
}
