//
//  TokenRefreshCoordinator.swift
//

import Alamofire
import Domain
import Model
import Foundation

/// Configuration for token refresh retry behavior.
public struct TokenRefreshConfiguration {

    /// Maximum number of retry attempts for failed refresh operations.
    public let maxRetryAttempts: Int
    
    /// Base delay in seconds for exponential backoff calculation.
    public let baseBackoffSeconds: Double
    
    /// Threshold in seconds before token expiration to trigger proactive refresh.
    /// Set to 0 to disable proactive refresh.
    public let proactiveRefreshThreshold: TimeInterval
    
    /// Default configuration with 2 retry attempts, 1 second base backoff, and 60 second proactive refresh threshold.
    public static let `default` = TokenRefreshConfiguration(
        maxRetryAttempts: 2,
        baseBackoffSeconds: 1.0,
        proactiveRefreshThreshold: 60.0
    )
    
    public init(maxRetryAttempts: Int, baseBackoffSeconds: Double, proactiveRefreshThreshold: TimeInterval = 60.0) {
        self.maxRetryAttempts = maxRetryAttempts
        self.baseBackoffSeconds = baseBackoffSeconds
        self.proactiveRefreshThreshold = proactiveRefreshThreshold
    }
}

/// Coordinates token refresh operations to ensure that concurrent callers share a single in-flight refresh request.
public actor TokenRefreshCoordinator: TokenRefreshCoordinatorProtocol {

    private static let nanosecondsPerSecond: UInt64 = 1_000_000_000
    
    private let configuration: TokenRefreshConfiguration

    private let sessionRepository: any SessionRepositoryProtocol
    private let refreshClient: any RefreshTokenClient

    private var refreshTask: Task<any TokenSetProtocol, Error>?

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
    /// Proactively refreshes the token if it's close to expiration.
    ///
    /// - Returns: The current valid access token
    /// - Throws: `APIAuthenticationError.missingToken` if no token set is available
    public func validAccessToken() async throws -> String {
        if let refreshTask {
            _ = try await refreshTask.value
        }

        guard let tokenSet = await sessionRepository.currentTokenSet() else {
            throw APIAuthenticationError.missingToken
        }

        if shouldProactivelyRefresh(tokenSet) {
            Task {
                try? await refresh()
            }
        }

        return tokenSet.accessToken
    }

    /// Performs a token refresh operation, coordinating concurrent requests.
    ///
    /// - Throws: `APIAuthenticationError` for authentication-specific failures, or the underlying network error
    public func refresh() async throws {
        if let existingTask = refreshTask {
            _ = try await existingTask.value
            return
        }

        let task = Task<any TokenSetProtocol, Error> {
            try await performRefresh()
        }
        
        refreshTask = task
        defer { refreshTask = nil }
        
        _ = try await task.value
    }

    private func performRefresh() async throws -> any TokenSetProtocol {
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
                return newTokenSet
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
    
    private func shouldProactivelyRefresh(_ tokenSet: any TokenSetProtocol) -> Bool {
        guard configuration.proactiveRefreshThreshold > 0,
              let expiresAt = tokenSet.expiresAt else {
            return false
        }
        
        let timeUntilExpiration = expiresAt.timeIntervalSinceNow
        return timeUntilExpiration > 0 && timeUntilExpiration <= configuration.proactiveRefreshThreshold
    }
}
