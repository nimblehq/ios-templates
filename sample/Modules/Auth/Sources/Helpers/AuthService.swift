import AuthInterface
import Foundation

/// Local-storage implementation of `AuthServiceProtocol`.
/// Persists session state in `UserDefaults` — suitable for demo purposes.
public final class AuthService: AuthServiceProtocol {

    private let defaults: UserDefaults
    private let emailKey = "auth_email"
    private let isLoggedInKey = "auth_is_logged_in"

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public var currentUser: User? {
        guard defaults.bool(forKey: isLoggedInKey),
              let email = defaults.string(forKey: emailKey) else {
            return nil
        }
        return User(email: email)
    }

    public func signIn(email: String, password: String) async throws {
        try validate(email: email, password: password)
        defaults.set(email, forKey: emailKey)
        defaults.set(true, forKey: isLoggedInKey)
    }

    public func signUp(email: String, password: String) async throws {
        try validate(email: email, password: password)
        defaults.set(email, forKey: emailKey)
        defaults.set(true, forKey: isLoggedInKey)
    }

    public func signOut() {
        defaults.removeObject(forKey: emailKey)
        defaults.set(false, forKey: isLoggedInKey)
    }

    // MARK: - Private

    private func validate(email: String, password: String) throws {
        guard !email.isEmpty, email.contains("@"), email.contains(".") else {
            throw AuthError.invalidEmail
        }
        guard !password.isEmpty else {
            throw AuthError.emptyPassword
        }
    }
}
