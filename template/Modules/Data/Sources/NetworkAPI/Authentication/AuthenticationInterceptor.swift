//
//  AuthenticationInterceptor.swift
//

import Alamofire
import Foundation

/// Alamofire interceptor that automatically handles authentication for HTTP requests.
///
/// This interceptor provides two key functions:
/// 1. **Request Adaptation**: Adds `Authorization: Bearer <token>` header to outgoing requests
/// 2. **Response Retry**: Automatically retries requests that fail with 401 status after refreshing the token
///
/// ## Usage Guidelines
/// - Use this interceptor for authenticated API endpoints
/// - **Do not use** for login and refresh endpoints to avoid infinite refresh loops
/// - Configure with a shared `TokenRefreshCoordinator` for proper coordination across multiple interceptors
///
/// ## Retry Behavior
/// - Only retries once per request on 401 responses
/// - Uses the configured `TokenRefreshCoordinator` to ensure only one refresh happens at a time
/// - If token refresh fails, the original error is propagated
///
/// ## Thread Safety
/// This class is thread-safe and can be used across multiple concurrent requests.
public final class AuthenticationInterceptor: RequestInterceptor {

    private let coordinator: TokenRefreshCoordinator

    public init(coordinator: TokenRefreshCoordinator) {
        self.coordinator = coordinator
    }

    /// Creates an interceptor with a dedicated coordinator.
    ///
    /// **Note**: Prefer sharing one `TokenRefreshCoordinator` via dependency injection when multiple
    /// interceptors must coordinate to avoid duplicate refresh operations.
    ///
    /// - Parameters:
    ///   - sessionRepository: Repository for managing authentication tokens
    ///   - refreshClient: Client for performing token refresh operations
    ///   - configuration: Configuration for retry behavior (uses default if not specified)
    public convenience init(
        sessionRepository: any SessionRepositoryProtocol,
        refreshClient: any RefreshTokenClient = DefaultRefreshTokenClient(),
        configuration: TokenRefreshConfiguration = .default
    ) {
        self.init(
            coordinator: TokenRefreshCoordinator(
                sessionRepository: sessionRepository,
                refreshClient: refreshClient,
                configuration: configuration
            )
        )
    }

    public func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping @Sendable (Result<URLRequest, any Error>) -> Void
    ) {
        Task {
            do {
                let accessToken = try await coordinator.validAccessToken()
                var request = urlRequest
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                completion(.success(request))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func retry(
        _ request: Request,
        for session: Session,
        dueTo error: any Error,
        completion: @escaping @Sendable (RetryResult) -> Void
    ) {
        guard let response = request.task?.response as? HTTPURLResponse,
              response.statusCode == 401,
              request.retryCount < 1 else {
            completion(.doNotRetryWithError(error))
            return
        }

        Task {
            do {
                try await coordinator.refresh()
                completion(.retry)
            } catch {
                completion(.doNotRetryWithError(error))
            }
        }
    }
}
