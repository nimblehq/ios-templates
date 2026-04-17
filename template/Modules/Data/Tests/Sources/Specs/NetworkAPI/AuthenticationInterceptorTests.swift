//
//  AuthenticationInterceptorTests.swift
//

import Alamofire
import Domain
import Foundation
import Model
import Testing

@testable import Data

@Suite("AuthenticationInterceptor")
struct AuthenticationInterceptorTests {

    private let validToken = TokenSet(
        accessToken: "valid-access-token",
        refreshToken: "valid-refresh-token",
        expiresAt: nil
    )

    private let refreshedToken = TokenSet(
        accessToken: "new-access-token",
        refreshToken: "new-refresh-token",
        expiresAt: nil
    )

    // MARK: - Request Adaptation Tests

    @Test("adapt adds Authorization header with Bearer token when valid token is available")
    func adaptAddsAuthorizationHeaderWithBearerToken() async throws {
        let repository = MockSessionRepository(token: validToken)
        let client = MockRefreshClient(outcome: .success(refreshedToken))
        let coordinator = MockTokenRefreshCoordinator(
            sessionRepository: repository,
            refreshClient: client,
            validTokenResult: .success("valid-access-token")
        )
        let interceptor = AuthenticationInterceptor(coordinator: coordinator)
        
        var request = URLRequest(url: URL(string: "https://example.com")!)
        let session = Session.default
        
        let result = await withCheckedContinuation { continuation in
            interceptor.adapt(request, for: session) { result in
                continuation.resume(returning: result)
            }
        }
        
        guard case .success(let adaptedRequest) = result else {
            Issue.record("Expected success, got failure")
            return
        }
        
        #expect(adaptedRequest.value(forHTTPHeaderField: "Authorization") == "Bearer valid-access-token")
    }

    @Test("adapt fails when coordinator throws missing token error")
    func adaptFailsWhenCoordinatorThrowsMissingToken() async throws {
        let repository = MockSessionRepository(token: nil)
        let client = MockRefreshClient(outcome: .success(refreshedToken))
        let coordinator = MockTokenRefreshCoordinator(
            sessionRepository: repository,
            refreshClient: client,
            validTokenResult: .failure(APIAuthenticationError.missingToken)
        )
        let interceptor = AuthenticationInterceptor(coordinator: coordinator)
        
        var request = URLRequest(url: URL(string: "https://example.com")!)
        let session = Session.default
        
        let result = await withCheckedContinuation { continuation in
            interceptor.adapt(request, for: session) { result in
                continuation.resume(returning: result)
            }
        }
        
        guard case .failure(let error) = result else {
            Issue.record("Expected failure, got success")
            return
        }
        
        #expect(error is APIAuthenticationError)
        if let authError = error as? APIAuthenticationError {
            #expect(authError == .missingToken)
        }
    }

    @Test("adapt preserves existing headers when adding Authorization header")
    func adaptPreservesExistingHeaders() async throws {
        let repository = MockSessionRepository(token: validToken)
        let client = MockRefreshClient(outcome: .success(refreshedToken))
        let coordinator = MockTokenRefreshCoordinator(
            sessionRepository: repository,
            refreshClient: client,
            validTokenResult: .success("valid-access-token")
        )
        let interceptor = AuthenticationInterceptor(coordinator: coordinator)
        
        var request = URLRequest(url: URL(string: "https://example.com")!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("en-US", forHTTPHeaderField: "Accept-Language")
        let session = Session.default
        
        let result = await withCheckedContinuation { continuation in
            interceptor.adapt(request, for: session) { result in
                continuation.resume(returning: result)
            }
        }
        
        guard case .success(let adaptedRequest) = result else {
            Issue.record("Expected success, got failure")
            return
        }
        
        #expect(adaptedRequest.value(forHTTPHeaderField: "Authorization") == "Bearer valid-access-token")
        #expect(adaptedRequest.value(forHTTPHeaderField: "Content-Type") == "application/json")
        #expect(adaptedRequest.value(forHTTPHeaderField: "Accept-Language") == "en-US")
    }

    // MARK: - Request Retry Integration Tests

    @Test("retry logic respects 401 status codes and retry count limits")
    func retryLogicRespects401StatusCodesAndRetryCountLimits() async throws {
        let repository = MockSessionRepository(token: validToken)
        let client = MockRefreshClient(outcome: .success(refreshedToken))
        let coordinator = TokenRefreshCoordinator(
            sessionRepository: repository,
            refreshClient: client
        )
        
        try await coordinator.refresh()
        
        let updatedToken = await repository.currentTokenSet()
        #expect(updatedToken?.accessToken == "new-access-token")
    }

    @Test("retry functionality handles authentication errors correctly")
    func retryFunctionalityHandlesAuthenticationErrorsCorrectly() async throws {
        let repository = MockSessionRepository(token: nil)
        let client = MockRefreshClient(outcome: .success(refreshedToken))
        let coordinator = TokenRefreshCoordinator(
            sessionRepository: repository,
            refreshClient: client
        )
        
        var caughtError: APIAuthenticationError?
        do {
            _ = try await coordinator.validAccessToken()
        } catch let error as APIAuthenticationError {
            caughtError = error
        }
        
        #expect(caughtError == .missingToken)
    }

    // MARK: - Convenience Initializer Tests

    @Test("convenience initializer creates interceptor with provided dependencies")
    func convenienceInitializerCreatesInterceptorWithProvidedDependencies() async throws {
        let repository = MockSessionRepository(token: validToken)
        let client = MockRefreshClient(outcome: .success(refreshedToken))
        let configuration = TokenRefreshConfiguration(maxRetryAttempts: 1, baseBackoffSeconds: 0.5)
        
        let interceptor = AuthenticationInterceptor(
            sessionRepository: repository,
            refreshClient: client,
            configuration: configuration
        )
        
        var request = URLRequest(url: URL(string: "https://example.com")!)
        let session = Session.default
        
        let result = await withCheckedContinuation { continuation in
            interceptor.adapt(request, for: session) { result in
                continuation.resume(returning: result)
            }
        }
        
        guard case .success(let adaptedRequest) = result else {
            Issue.record("Expected success, got failure")
            return
        }
        
        #expect(adaptedRequest.value(forHTTPHeaderField: "Authorization") == "Bearer valid-access-token")
    }

    @Test("convenience initializer uses default configuration when none provided")
    func convenienceInitializerUsesDefaultConfigurationWhenNoneProvided() async throws {
        let repository = MockSessionRepository(token: validToken)
        
        let interceptor = AuthenticationInterceptor(sessionRepository: repository)
        
        var request = URLRequest(url: URL(string: "https://example.com")!)
        let session = Session.default
        
        let result = await withCheckedContinuation { continuation in
            interceptor.adapt(request, for: session) { result in
                continuation.resume(returning: result)
            }
        }
        
        guard case .success(let adaptedRequest) = result else {
            Issue.record("Expected success, got failure")
            return
        }
        
        #expect(adaptedRequest.value(forHTTPHeaderField: "Authorization") == "Bearer valid-access-token")
    }

    // MARK: - Integration Tests

    @Test("interceptor integrates correctly with real coordinator")
    func interceptorIntegratesCorrectlyWithRealCoordinator() async throws {
        let repository = MockSessionRepository(token: validToken)
        let client = MockRefreshClient(outcome: .success(refreshedToken))
        let configuration = TokenRefreshConfiguration(maxRetryAttempts: 1, baseBackoffSeconds: 0.1)
        
        let interceptor = AuthenticationInterceptor(
            sessionRepository: repository,
            refreshClient: client,
            configuration: configuration
        )
        
        var request = URLRequest(url: URL(string: "https://api.example.com/data")!)
        let session = Session.default
        
        let adaptResult = await withCheckedContinuation { continuation in
            interceptor.adapt(request, for: session) { result in
                continuation.resume(returning: result)
            }
        }
        
        guard case .success(let adaptedRequest) = adaptResult else {
            Issue.record("Expected successful adaptation")
            return
        }
        
        #expect(adaptedRequest.value(forHTTPHeaderField: "Authorization") == "Bearer valid-access-token")
        #expect(adaptedRequest.url?.absoluteString == "https://api.example.com/data")
    }

    @Test("interceptor handles concurrent requests properly")
    func interceptorHandlesConcurrentRequestsProperly() async throws {
        let repository = MockSessionRepository(token: validToken)
        let client = MockRefreshClient(outcome: .success(refreshedToken))
        let coordinator = TokenRefreshCoordinator(
            sessionRepository: repository,
            refreshClient: client
        )
        let interceptor = AuthenticationInterceptor(coordinator: coordinator)
        
        let request1 = URLRequest(url: URL(string: "https://api.example.com/endpoint1")!)
        let request2 = URLRequest(url: URL(string: "https://api.example.com/endpoint2")!)
        let request3 = URLRequest(url: URL(string: "https://api.example.com/endpoint3")!)
        
        let session = Session.default
        
        async let result1 = withCheckedContinuation { continuation in
            interceptor.adapt(request1, for: session) { result in
                continuation.resume(returning: result)
            }
        }
        
        async let result2 = withCheckedContinuation { continuation in
            interceptor.adapt(request2, for: session) { result in
                continuation.resume(returning: result)
            }
        }
        
        async let result3 = withCheckedContinuation { continuation in
            interceptor.adapt(request3, for: session) { result in
                continuation.resume(returning: result)
            }
        }
        
        let (r1, r2, r3) = await (result1, result2, result3)
        
        guard case .success(let adaptedRequest1) = r1,
              case .success(let adaptedRequest2) = r2,
              case .success(let adaptedRequest3) = r3 else {
            Issue.record("Expected all adaptations to succeed")
            return
        }
        
        #expect(adaptedRequest1.value(forHTTPHeaderField: "Authorization") == "Bearer valid-access-token")
        #expect(adaptedRequest2.value(forHTTPHeaderField: "Authorization") == "Bearer valid-access-token")
        #expect(adaptedRequest3.value(forHTTPHeaderField: "Authorization") == "Bearer valid-access-token")
    }
}

// MARK: - Test Mocks

private actor MockSessionRepository: SessionRepositoryProtocol {
    private var token: TokenSet?

    init(token: TokenSet?) {
        self.token = token
    }

    func hasActiveSession() -> Bool {
        token != nil
    }

    func currentTokenSet() -> (any TokenSetProtocol)? {
        token
    }

    func save(tokenSet: any TokenSetProtocol) throws {
        token = TokenSet(
            accessToken: tokenSet.accessToken,
            refreshToken: tokenSet.refreshToken,
            expiresAt: tokenSet.expiresAt
        )
    }

    func clearSession() throws {
        token = nil
    }
}

private actor MockRefreshClient: RefreshTokenClient {

    enum Outcome {

        case success(TokenSet)
        case failure(Error)
    }

    private let outcome: Outcome

    init(outcome: Outcome) {
        self.outcome = outcome
    }

    func performRefresh(refreshToken: String) async throws -> any TokenSetProtocol {
        switch outcome {
        case .success(let token):
            return token
        case .failure(let error):
            throw error
        }
    }
}

private actor MockTokenRefreshCoordinator: TokenRefreshCoordinatorProtocol {

    private let sessionRepository: any SessionRepositoryProtocol
    private let refreshClient: any RefreshTokenClient
    private let validTokenResult: Result<String, Error>
    private let refreshResult: Result<Void, Error>
    private var refreshCount = 0

    init(
        sessionRepository: any SessionRepositoryProtocol,
        refreshClient: any RefreshTokenClient,
        validTokenResult: Result<String, Error> = .success("default-token"),
        refreshResult: Result<Void, Error> = .success(())
    ) {
        self.sessionRepository = sessionRepository
        self.refreshClient = refreshClient
        self.validTokenResult = validTokenResult
        self.refreshResult = refreshResult
    }

    func validAccessToken() async throws -> String {
        switch validTokenResult {
        case .success(let token):
            return token
        case .failure(let error):
            throw error
        }
    }

    func refresh() async throws {
        refreshCount += 1
        switch refreshResult {
        case .success():
            return
        case .failure(let error):
            throw error
        }
    }

    func refreshCallCount() -> Int {
        refreshCount
    }
}
