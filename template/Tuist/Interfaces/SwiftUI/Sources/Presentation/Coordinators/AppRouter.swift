import SwiftUI

@MainActor
final class AppRouter: ObservableObject {

    @Published var path: [AppRoute] = []
    @Published var fullScreenRoute: AppRoute?

    func push(_ route: AppRoute) {
        path.append(route)
    }

    func presentFullScreen(_ route: AppRoute) {
        fullScreenRoute = route
    }

    func pop() {
        guard !path.isEmpty else { return }

        path.removeLast()
    }

    func popToRoot() {
        path.removeAll()
    }

    func dismissFullScreen() {
        fullScreenRoute = nil
    }
}
