import Auth
import SwiftUI

/// Standalone sandbox for developing and testing the Auth feature in isolation.
@main
struct AuthExampleApp: App {

    private let authService = AuthService()
    @State private var isAuthenticated = false

    var body: some Scene {
        WindowGroup {
            if isAuthenticated {
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.green)
                    Text("Signed in as \(authService.currentUser?.email ?? "")")
                        .font(.headline)
                    Button("Sign Out", role: .destructive) {
                        authService.signOut()
                        isAuthenticated = false
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            } else {
                AuthRootView(authService: authService) {
                    isAuthenticated = true
                }
            }
        }
    }
}
