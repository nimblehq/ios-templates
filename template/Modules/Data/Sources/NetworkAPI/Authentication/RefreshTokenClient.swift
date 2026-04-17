//
//  RefreshTokenClient.swift
//

import Alamofire
import Foundation
import Model

/// Protocol for clients that can perform token refresh operations.
public protocol RefreshTokenClient: Sendable {

    /// Performs a token refresh using the provided refresh token.
    ///
    /// - Parameter refreshToken: The refresh token to exchange for new tokens
    /// - Returns: A new token set containing fresh access and refresh tokens
    /// - Throws: Network or authentication errors if the refresh fails
    func performRefresh(refreshToken: String) async throws -> any TokenSetProtocol
}

/// Default implementation of `RefreshTokenClient` using Alamofire for network requests.
///
/// This implementation uses the `AuthRequestConfiguration.refreshToken` configuration to perform
/// the refresh request and expects the response to be decodable as a `TokenSet`.
public final class DefaultRefreshTokenClient: RefreshTokenClient, @unchecked Sendable {

    private let decoder: JSONDecoder
    private let session: Session

    public init(decoder: JSONDecoder = JSONDecoder(), session: Session = Session()) {
        self.decoder = decoder
        self.session = session
    }

    public func performRefresh(refreshToken: String) async throws -> any TokenSetProtocol {
        let configuration = AuthRequestConfiguration.refreshToken(refreshToken)
        let tokenSet: TokenSet = try await request(
            session: session,
            configuration: configuration,
            decoder: decoder
        )
        return tokenSet
    }
    
    private func request<T: Decodable & Sendable>(
        session: Session,
        configuration: RequestConfiguration,
        decoder: JSONDecoder
    ) async throws -> T {
        try await session.request(
            configuration.url,
            method: configuration.method,
            parameters: configuration.parameters,
            encoding: configuration.encoding,
            headers: configuration.headers,
            interceptor: configuration.interceptor
        )
        .validate()
        .serializingDecodable(T.self, decoder: decoder)
        .value
    }
}
