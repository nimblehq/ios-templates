import SwiftUI

@MainActor
final class AppRouter: ObservableObject {

    @Published var path: [AppRoute] = []

    func push(_ route: AppRoute) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }

        path.removeLast()
    }

    func popToRoot() {
        path.removeAll()
    }
}
