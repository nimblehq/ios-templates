import Foundation

public enum AuthError: LocalizedError, Equatable {
    case invalidEmail
    case emptyPassword
    case invalidCredentials

    public var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Please enter a valid email address."
        case .emptyPassword:
            return "Password cannot be empty."
        case .invalidCredentials:
            return "Invalid email or password."
        }
    }
}
