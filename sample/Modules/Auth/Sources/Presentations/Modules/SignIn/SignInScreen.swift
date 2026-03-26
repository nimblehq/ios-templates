import AuthInterface
import SwiftUI

struct SignInScreen: View {

    @StateObject private var viewModel: SignInViewModel
    let onNavigateToSignUp: () -> Void

    init(
        authService: any AuthServiceProtocol,
        onSignedIn: @escaping () -> Void,
        onNavigateToSignUp: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: SignInViewModel(
            authService: authService,
            onSignedIn: onSignedIn
        ))
        self.onNavigateToSignUp = onNavigateToSignUp
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Sign In")
                .font(.largeTitle.bold())

            VStack(spacing: 12) {
                TextField("Email", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .textFieldStyle(.roundedBorder)

                SecureField("Password", text: $viewModel.password)
                    .textContentType(.password)
                    .textFieldStyle(.roundedBorder)
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }

            Button {
                Task { await viewModel.signIn() }
            } label: {
                Group {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Text("Sign In")
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading)

            Button("Don't have an account? Sign Up") {
                onNavigateToSignUp()
            }
            .font(.footnote)

            Spacer()
        }
        .padding(.horizontal, 32)
    }
}
