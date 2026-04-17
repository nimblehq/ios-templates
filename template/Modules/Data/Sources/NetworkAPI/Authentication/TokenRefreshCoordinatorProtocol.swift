//
//  TokenRefreshCoordinatorProtocol.swift
//

/// Describes the coordinator responsible for obtaining a valid access token and refreshing it.
public protocol TokenRefreshCoordinatorProtocol: Actor {

    /// Returns the current valid access token.
    ///
    /// - Throws: `APIAuthenticationError.missingToken` if no token set is available
    func validAccessToken() async throws -> String
    /// Performs a token refresh, coordinating concurrent callers so only one in-flight refresh occurs.
    ///
    /// - Throws: `APIAuthenticationError` or the underlying network error on failure
    func refresh() async throws
}
