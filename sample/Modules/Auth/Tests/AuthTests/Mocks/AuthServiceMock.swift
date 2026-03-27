import Foundation
@testable import Auth

final class AuthServiceMock: AuthServiceProtocol {

    var currentUser: User?
    var shouldThrowOnSignIn: AuthError?
    var shouldThrowOnSignUp: AuthError?

    // Call tracking
    private(set) var signInCallCount = 0
    private(set) var signUpCallCount = 0
    private(set) var signOutCallCount = 0
    private(set) var lastSignInEmail: String?
    private(set) var lastSignUpEmail: String?

    init() {}

    public func signIn(email: String, password: String) async throws {
        signInCallCount += 1
        lastSignInEmail = email
        if let error = shouldThrowOnSignIn { throw error }
        currentUser = User(email: email)
    }

    public func signUp(email: String, password: String) async throws {
        signUpCallCount += 1
        lastSignUpEmail = email
        if let error = shouldThrowOnSignUp { throw error }
        currentUser = User(email: email)
    }

    public func signOut() {
        signOutCallCount += 1
        currentUser = nil
    }
}
