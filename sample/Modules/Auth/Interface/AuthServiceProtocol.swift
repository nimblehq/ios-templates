import Foundation

public protocol AuthServiceProtocol: AnyObject {

    /// The currently authenticated user, or `nil` if no session is active.
    var currentUser: User? { get }

    /// Authenticates with email and password.
    /// - Throws: `AuthError` for validation failures.
    func signIn(email: String, password: String) async throws

    /// Creates a new account with email and password.
    /// - Throws: `AuthError` for validation failures.
    func signUp(email: String, password: String) async throws

    /// Clears the current session.
    func signOut()
}
