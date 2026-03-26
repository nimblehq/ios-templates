import AuthInterface
import Combine
import Foundation

@MainActor
final class SignUpViewModel: ObservableObject {

    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let authService: any AuthServiceProtocol
    private let onSignedUp: () -> Void

    init(authService: any AuthServiceProtocol, onSignedUp: @escaping () -> Void) {
        self.authService = authService
        self.onSignedUp = onSignedUp
    }

    func signUp() async {
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            try await authService.signUp(email: email, password: password)
            onSignedUp()
        } catch let error as AuthError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
