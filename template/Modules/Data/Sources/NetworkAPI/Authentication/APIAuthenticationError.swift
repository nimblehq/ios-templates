//
//  APIAuthenticationError.swift
//

import Foundation

/// Errors that can occur during authentication operations.
public enum APIAuthenticationError: Error, Equatable {

    /// No authentication token is available in the session repository.
    case missingToken
    
    /// The refresh token has expired or is invalid (typically a 401 response from refresh endpoint).
    case refreshTokenExpired
    
    /// Token refresh failed after all retry attempts were exhausted.
    /// - Parameters:
    ///   - underlyingError: Description of the underlying error that caused the failure
    ///   - attemptCount: Total number of refresh attempts made
    case refreshFailed(underlyingError: String, attemptCount: Int)
}
