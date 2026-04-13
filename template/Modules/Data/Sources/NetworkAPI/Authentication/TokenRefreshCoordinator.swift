//
//  TokenRefreshCoordinator.swift
//

import Alamofire
import Domain
import Foundation

/// Configuration for token refresh retry behavior.
public struct TokenRefreshConfiguration {
    /// Maximum number of retry attempts for failed refresh operations.
    public let maxRetryAttempts: Int
    
    /// Base delay in seconds for exponential backoff calculation.
    public let baseBackoffSeconds: Double
    
    /// Default configuration with 2 retry attempts and 1 second base backoff.
    public static let `default` = TokenRefreshConfiguration(
        maxRetryAttempts: 2,
        baseBackoffSeconds: 1.0
    )
    
    public init(maxRetryAttempts: Int, baseBackoffSeconds: Double) {
        self.maxRetryAttempts = maxRetryAttempts
        self.baseBackoffSeconds = baseBackoffSeconds
    }
}

/// Coordinates token refresh operations to ensure that concurrent callers share a single in-flight refresh request.
public actor TokenRefreshCoordinator {

    /// Maximum number of retry attempts for failed refresh operations.
    public static let maxRetryAttempts = 2
    private static let nanosecondsPerSecond: UInt64 = 1_000_000_000
    
    private let configuration: TokenRefreshConfiguration

    private let sessionRepository: any SessionRepositoryProtocol
    private let refreshClient: any RefreshTokenClient

    private var isRefreshing = false
    private var pendingContinuations: [CheckedContinuation<Void, any Error>] = []

    public init(
        sessionRepository: any SessionRepositoryProtocol,
        refreshClient: any RefreshTokenClient,
        configuration: TokenRefreshConfiguration = .default
    ) {
        self.sessionRepository = sessionRepository
        self.refreshClient = refreshClient
        self.configuration = configuration
    }

    /// Returns the current access token, waiting if a refresh is already in progress.
    ///
    /// - Returns: The current valid access token
    /// - Throws: `APIAuthenticationError.missingToken` if no token set is available
    public func validAccessToken() async throws -> String {
        if isRefreshing {
            try await withCheckedThrowingContinuation { continuation in
                pendingContinuations.append(continuation)
            }
        }

        guard let tokenSet = await sessionRepository.currentTokenSet() else {
            throw APIAuthenticationError.missingToken
        }

        return tokenSet.accessToken
    }

    /// Performs a token refresh operation, coordinating concurrent requests.
    ///
    /// - Throws: `APIAuthenticationError` for authentication-specific failures, or the underlying network error
    public func refresh() async throws {
        if isRefreshing {
            try await withCheckedThrowingContinuation { continuation in
                pendingContinuations.append(continuation)
            }
            return
        }

        isRefreshing = true

        do {
            try await performRefresh()
            resumeAll(throwing: nil)
        } catch {
            resumeAll(throwing: error)
            throw error
        }
    }

    private func resumeAll(throwing error: (any Error)?) {
        isRefreshing = false
        let continuations = pendingContinuations
        pendingContinuations = []
        for continuation in continuations {
            if let error {
                continuation.resume(throwing: error)
            } else {
                continuation.resume()
            }
        }
    }

    private func performRefresh() async throws {
        guard let currentTokenSet = await sessionRepository.currentTokenSet() else {
            await clearSessionIgnoringError()
            throw APIAuthenticationError.missingToken
        }

        var lastError: (any Error)?

        for attempt in 0...configuration.maxRetryAttempts {
            if attempt > 0 {
                let backoffDelay = calculateBackoffDelay(for: attempt)
                try await Task.sleep(nanoseconds: backoffDelay)
            }

            do {
                let newTokenSet = try await refreshClient.performRefresh(
                    refreshToken: currentTokenSet.refreshToken
                )
                try await sessionRepository.save(tokenSet: newTokenSet)
                return
            } catch {
                if let afError = error.asAFError, afError.responseCode == 401 {
                    await clearSessionIgnoringError()
                    throw APIAuthenticationError.refreshTokenExpired
                }
                lastError = error
            }
        }

        await clearSessionIgnoringError()
        let errorDescription = lastError?.localizedDescription ?? "Unknown refresh error"
        throw APIAuthenticationError.refreshFailed(
            underlyingError: errorDescription,
            attemptCount: configuration.maxRetryAttempts + 1
        )
    }

    private func clearSessionIgnoringError() async {
        try? await sessionRepository.clearSession()
    }
    
    private func calculateBackoffDelay(for attempt: Int) -> UInt64 {
        let backoffSeconds = configuration.baseBackoffSeconds * pow(2.0, Double(attempt - 1))
        return UInt64(backoffSeconds * Double(Self.nanosecondsPerSecond))
    }
}
