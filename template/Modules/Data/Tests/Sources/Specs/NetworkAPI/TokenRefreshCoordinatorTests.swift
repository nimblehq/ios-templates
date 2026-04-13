//
//  TokenRefreshCoordinatorTests.swift
//

import Alamofire
import Domain
import Foundation
import Model
import Testing

@testable import Data

@Suite("TokenRefreshCoordinator")
struct TokenRefreshCoordinatorTests {

    private let initialToken = TokenSet(
        accessToken: "access",
        refreshToken: "refresh",
        expiresAt: nil
    )

    private let refreshedToken = TokenSet(
        accessToken: "access-new",
        refreshToken: "refresh-new",
        expiresAt: nil
    )

    @Test("returns the access token when a session exists")
    func returnsAccessTokenWhenSessionExists() async throws {
        let repository = MockSessionRepository(token: initialToken)
        let client = CountingRefreshClient(outcome: .success(refreshedToken))
        let coordinator = TokenRefreshCoordinator(sessionRepository: repository, refreshClient: client)

        let token = try await coordinator.validAccessToken()

        #expect(token == "access")
        #expect(await client.performRefreshCount() == 0)
    }

    @Test("throws missingToken when there is no session")
    func throwsMissingTokenWhenThereIsNoSession() async {
        let repository = MockSessionRepository(token: nil)
        let client = CountingRefreshClient(outcome: .success(refreshedToken))
        let coordinator = TokenRefreshCoordinator(sessionRepository: repository, refreshClient: client)

        var caught: AuthenticationError?
        do {
            _ = try await coordinator.validAccessToken()
        } catch let error as AuthenticationError {
            caught = error
        } catch {
            Issue.record("Expected AuthenticationError, got \(error)")
        }
        #expect(caught == .missingToken)
    }

    @Test("persists tokens returned from refresh")
    func persistsTokensReturnedFromRefresh() async throws {
        let repository = MockSessionRepository(token: initialToken)
        let client = CountingRefreshClient(outcome: .success(refreshedToken))
        let coordinator = TokenRefreshCoordinator(sessionRepository: repository, refreshClient: client)

        try await coordinator.refresh()

        let stored = await repository.currentTokenSet()
        #expect(stored?.accessToken == "access-new")
        #expect(await client.performRefreshCount() == 1)
    }

    @Test("coalesces concurrent refresh calls into a single refresh")
    func coalescesConcurrentRefreshCalls() async throws {
        let repository = MockSessionRepository(token: initialToken)
        let client = CountingRefreshClient(outcome: .success(refreshedToken))
        let coordinator = TokenRefreshCoordinator(sessionRepository: repository, refreshClient: client)

        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                try await coordinator.refresh()
            }
            group.addTask {
                try await coordinator.refresh()
            }
            for try await _ in group {}
        }

        #expect(await client.performRefreshCount() == 1)
    }

    @Test("clears the session when refresh responds with 401")
    func clearsSessionWhenRefreshRespondsWith401() async {
        let repository = MockSessionRepository(token: initialToken)
        let unauthorized = AFError.responseValidationFailed(
            reason: .unacceptableStatusCode(code: 401)
        )
        let client = CountingRefreshClient(outcome: .failure(unauthorized))
        let coordinator = TokenRefreshCoordinator(sessionRepository: repository, refreshClient: client)

        var caught: AuthenticationError?
        do {
            try await coordinator.refresh()
        } catch let error as AuthenticationError {
            caught = error
        } catch {
            Issue.record("Expected AuthenticationError, got \(error)")
        }
        #expect(caught == .refreshTokenExpired)

        let stored = await repository.currentTokenSet()
        #expect(stored == nil)
    }

    @Test("clears the session after refresh retries are exhausted")
    func clearsSessionAfterRefreshRetriesExhausted() async {
        let repository = MockSessionRepository(token: initialToken)
        let client = CountingRefreshClient(outcome: .failure(URLError(.cannotConnectToHost)))
        let coordinator = TokenRefreshCoordinator(sessionRepository: repository, refreshClient: client)

        var caughtError: AuthenticationError?
        do {
            try await coordinator.refresh()
        } catch let error as AuthenticationError {
            caughtError = error
        } catch {
            Issue.record("Expected AuthenticationError, got \(error)")
        }
        
        if case .refreshFailed(_, let attemptCount) = caughtError {
            #expect(attemptCount == TokenRefreshConfiguration.default.maxRetryAttempts + 1)
        } else {
            Issue.record("Expected refreshFailed error")
        }

        let stored = await repository.currentTokenSet()
        #expect(stored == nil)
        #expect(await client.performRefreshCount() == TokenRefreshConfiguration.default.maxRetryAttempts + 1)
    }
}

// MARK: - Mocks

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

private actor CountingRefreshClient: RefreshTokenClient {

    enum Outcome {
        case success(TokenSet)
        case failure(Error)
    }

    private let outcome: Outcome
    private var count = 0

    init(outcome: Outcome) {
        self.outcome = outcome
    }

    func performRefresh(refreshToken: String) async throws -> any TokenSetProtocol {
        count += 1
        switch outcome {
        case .success(let token):
            return token
        case .failure(let error):
            throw error
        }
    }

    func performRefreshCount() -> Int {
        count
    }
}
