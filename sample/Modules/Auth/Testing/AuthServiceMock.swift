import Auth
import Foundation

public final class AuthServiceMock: AuthServiceProtocol {

    public var currentUser: User?
    public var shouldThrowOnSignIn: AuthError?
    public var shouldThrowOnSignUp: AuthError?

    // Call tracking
    public private(set) var signInCallCount = 0
    public private(set) var signUpCallCount = 0
    public private(set) var signOutCallCount = 0
    public private(set) var lastSignInEmail: String?
    public private(set) var lastSignUpEmail: String?

    public init() {}

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
