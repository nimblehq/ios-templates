import Auth
import AuthInterface
import Home
import SwiftUI

@main
struct SampleApp: App {

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

private struct RootView: View {

    private let authService: AuthService
    @State private var isAuthenticated: Bool

    init() {
        let service = AuthService()
        authService = service
        _isAuthenticated = State(initialValue: service.currentUser != nil)
    }

    var body: some View {
        if isAuthenticated {
            HomeScreen()
        } else {
            AuthRootView(authService: authService) {
                isAuthenticated = true
            }
        }
    }
}
