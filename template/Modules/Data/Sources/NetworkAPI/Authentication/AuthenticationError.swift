//
//  AuthenticationError.swift
//

import Foundation

/// Errors that can occur during authentication operations.
public enum AuthenticationError: Error, Equatable {

    /// No authentication token is available in the session repository.
    case missingToken
    
    /// The refresh token has expired or is invalid (typically a 401 response from refresh endpoint).
    case refreshTokenExpired
    
    /// Token refresh failed after all retry attempts were exhausted.
    /// - Parameters:
    ///   - underlyingError: Description of the underlying error that caused the failure
    ///   - attemptCount: Total number of refresh attempts made
    case refreshFailed(underlyingError: String, attemptCount: Int)
    
    /// A network-related error occurred during authentication.
    /// - Parameter: Description of the network error
    case networkError(String)
    
    public static func == (lhs: AuthenticationError, rhs: AuthenticationError) -> Bool {
        switch (lhs, rhs) {
        case (.missingToken, .missingToken),
             (.refreshTokenExpired, .refreshTokenExpired):
            return true
        case (.refreshFailed(let lhsError, let lhsCount), .refreshFailed(let rhsError, let rhsCount)):
            return lhsError == rhsError && lhsCount == rhsCount
        case (.networkError(let lhsError), .networkError(let rhsError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}
