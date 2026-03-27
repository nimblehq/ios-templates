import Combine
import Foundation

@MainActor
final class SignInViewModel: ObservableObject {

    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let authService: any AuthServiceProtocol
    private let onSignedIn: () -> Void

    init(authService: any AuthServiceProtocol, onSignedIn: @escaping () -> Void) {
        self.authService = authService
        self.onSignedIn = onSignedIn
    }

    func signIn() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            try await authService.signIn(email: email, password: password)
            onSignedIn()
        } catch let error as AuthError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
