import SwiftUI

public struct AuthScreen: View {

    private let authService: any AuthServiceProtocol
    private let onAuthenticated: () -> Void

    public init(
        authService: any AuthServiceProtocol,
        onAuthenticated: @escaping () -> Void
    ) {
        self.authService = authService
        self.onAuthenticated = onAuthenticated
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Spacer()

                Text("Welcome")
                    .font(.largeTitle.bold())

                NavigationLink {
                    SignInScreen(
                        authService: authService,
                        onSignedIn: onAuthenticated,
                        onNavigateToSignUp: {}
                    )
                } label: {
                    Text("Sign In")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                NavigationLink {
                    SignUpScreen(
                        authService: authService,
                        onSignedUp: onAuthenticated,
                        onNavigateToSignIn: {}
                    )
                } label: {
                    Text("Sign Up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Spacer()
            }
            .padding(.horizontal, 32)
        }
    }
}
