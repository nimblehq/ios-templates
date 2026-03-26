import AuthInterface
import SwiftUI

struct SignUpScreen: View {

    @StateObject private var viewModel: SignUpViewModel
    let onNavigateToSignIn: () -> Void

    init(
        authService: any AuthServiceProtocol,
        onSignedUp: @escaping () -> Void,
        onNavigateToSignIn: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: SignUpViewModel(
            authService: authService,
            onSignedUp: onSignedUp
        ))
        self.onNavigateToSignIn = onNavigateToSignIn
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Create Account")
                .font(.largeTitle.bold())

            VStack(spacing: 12) {
                TextField("Email", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .textFieldStyle(.roundedBorder)

                SecureField("Password", text: $viewModel.password)
                    .textContentType(.newPassword)
                    .textFieldStyle(.roundedBorder)

                SecureField("Confirm Password", text: $viewModel.confirmPassword)
                    .textContentType(.newPassword)
                    .textFieldStyle(.roundedBorder)
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }

            Button {
                Task { await viewModel.signUp() }
            } label: {
                Group {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Text("Sign Up")
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading)

            Button("Already have an account? Sign In") {
                onNavigateToSignIn()
            }
            .font(.footnote)

            Spacer()
        }
        .padding(.horizontal, 32)
    }
}
