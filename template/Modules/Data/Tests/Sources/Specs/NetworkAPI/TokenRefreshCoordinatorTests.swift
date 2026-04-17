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
    func throwsMissingTokenWhenThereIsNoSession() async throws {
        let repository = MockSessionRepository(token: nil)
        let client = CountingRefreshClient(outcome: .success(refreshedToken))
        let coordinator = TokenRefreshCoordinator(sessionRepository: repository, refreshClient: client)

        await #expect(throws: APIAuthenticationError.missingToken) {
            try await coordinator.validAccessToken()
        }
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

    @Test("clears the session when refresh responds with 401")
    func clearsSessionWhenRefreshRespondsWith401() async throws {
        let repository = MockSessionRepository(token: initialToken)
        let unauthorized = AFError.responseValidationFailed(
            reason: .unacceptableStatusCode(code: 401)
        )
        let client = CountingRefreshClient(outcome: .failure(unauthorized))
        let coordinator = TokenRefreshCoordinator(sessionRepository: repository, refreshClient: client)

        await #expect(throws: APIAuthenticationError.refreshTokenExpired) {
            try await coordinator.refresh()
        }

        let stored = await repository.currentTokenSet()
        #expect(stored == nil)
    }

    @Test("clears the session after refresh retries are exhausted")
    func clearsSessionAfterRefreshRetriesExhausted() async throws {
        let repository = MockSessionRepository(token: initialToken)
        let client = CountingRefreshClient(outcome: .failure(URLError(.cannotConnectToHost)))
        let coordinator = TokenRefreshCoordinator(sessionRepository: repository, refreshClient: client)

        let caughtError = await #expect(throws: APIAuthenticationError.self) {
            try await coordinator.refresh()
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

    // MARK: - Concurrent Access Tests

    @Test("concurrent validAccessToken calls wait for single refresh operation")
    func concurrentValidAccessTokenCallsWaitForSingleRefresh() async throws {
        let repository = MockSessionRepository(token: initialToken)
        let delayedClient = DelayedRefreshClient(outcome: .success(refreshedToken), delay: 0.1)
        let coordinator = TokenRefreshCoordinator(
            sessionRepository: repository,
            refreshClient: delayedClient,
            configuration: TokenRefreshConfiguration(maxRetryAttempts: 1, baseBackoffSeconds: 0.1)
        )

        let refreshTask = Task {
            try await coordinator.refresh()
        }

        try await Task.sleep(nanoseconds: 50_000_000)

        async let token1 = coordinator.validAccessToken()
        async let token2 = coordinator.validAccessToken()
        async let token3 = coordinator.validAccessToken()

        try await refreshTask.value

        let (t1, t2, t3) = try await (token1, token2, token3)
        #expect(t1 == "access-new")
        #expect(t2 == "access-new")
        #expect(t3 == "access-new")

        #expect(await delayedClient.performRefreshCount() == 1)
    }

    @Test("concurrent refresh calls share single operation")
    func concurrentRefreshCallsShareSingleOperation() async throws {
        let repository = MockSessionRepository(token: initialToken)
        let delayedClient = DelayedRefreshClient(outcome: .success(refreshedToken), delay: 0.1)
        let coordinator = TokenRefreshCoordinator(
            sessionRepository: repository,
            refreshClient: delayedClient,
            configuration: TokenRefreshConfiguration(maxRetryAttempts: 1, baseBackoffSeconds: 0.1)
        )

        async let refresh1 = coordinator.refresh()
        async let refresh2 = coordinator.refresh()
        async let refresh3 = coordinator.refresh()

        try await refresh1
        try await refresh2
        try await refresh3

        #expect(await delayedClient.performRefreshCount() == 1)

        let stored = await repository.currentTokenSet()
        #expect(stored?.accessToken == "access-new")
    }

    @Test("proactive refresh triggers when token is close to expiration")
    func proactiveRefreshTriggersWhenTokenCloseToExpiration() async throws {
        let soonToExpireToken = TokenSet(
            accessToken: "access",
            refreshToken: "refresh",
            expiresAt: Date().addingTimeInterval(30)
        )
        let repository = MockSessionRepository(token: soonToExpireToken)
        let client = CountingRefreshClient(outcome: .success(refreshedToken))
        let coordinator = TokenRefreshCoordinator(
            sessionRepository: repository,
            refreshClient: client,
            configuration: TokenRefreshConfiguration(
                maxRetryAttempts: 1,
                baseBackoffSeconds: 0.1,
                proactiveRefreshThreshold: 60.0
            )
        )

        let token = try await coordinator.validAccessToken()
        #expect(token == "access") // Returns current token immediately

        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(await client.performRefreshCount() == 1)
    }

    @Test("proactive refresh does not trigger when token is not expiring soon")
    func proactiveRefreshDoesNotTriggerWhenTokenNotExpiringSoon() async throws {
        let longLivedToken = TokenSet(
            accessToken: "access",
            refreshToken: "refresh",
            expiresAt: Date().addingTimeInterval(3600)
        )
        let repository = MockSessionRepository(token: longLivedToken)
        let client = CountingRefreshClient(outcome: .success(refreshedToken))
        let coordinator = TokenRefreshCoordinator(
            sessionRepository: repository,
            refreshClient: client,
            configuration: TokenRefreshConfiguration(
                maxRetryAttempts: 1,
                baseBackoffSeconds: 0.1,
                proactiveRefreshThreshold: 60.0
            )
        )

        let token = try await coordinator.validAccessToken()
        #expect(token == "access")

        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(await client.performRefreshCount() == 0)
    }

    @Test("refresh backoff delays increase exponentially")
    func refreshBackoffDelaysIncreaseExponentially() async throws {
        let repository = MockSessionRepository(token: initialToken)
        let client = TimingRefreshClient(outcome: .failure(URLError(.cannotConnectToHost)))
        let startTime = Date()
        let coordinator = TokenRefreshCoordinator(
            sessionRepository: repository,
            refreshClient: client,
            configuration: TokenRefreshConfiguration(
                maxRetryAttempts: 2,
                baseBackoffSeconds: 0.1
            )
        )

        var caughtError: APIAuthenticationError?
        do {
            try await coordinator.refresh()
        } catch let error as APIAuthenticationError {
            caughtError = error
        }

        let endTime = Date()
        let totalDuration = endTime.timeIntervalSince(startTime)

        #expect(totalDuration >= 0.25)

        #expect(await client.performRefreshCount() == 3)
        
        if case .refreshFailed(_, let attemptCount) = caughtError {
            #expect(attemptCount == 3)
        } else {
            Issue.record("Expected refreshFailed error")
        }
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

private actor DelayedRefreshClient: RefreshTokenClient {

    enum Outcome {

        case success(TokenSet)
        case failure(Error)
    }

    private let outcome: Outcome
    private let delay: TimeInterval
    private var count = 0

    init(outcome: Outcome, delay: TimeInterval) {
        self.outcome = outcome
        self.delay = delay
    }

    func performRefresh(refreshToken: String) async throws -> any TokenSetProtocol {
        count += 1
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        
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

private actor TimingRefreshClient: RefreshTokenClient {

    enum Outcome {

        case success(TokenSet)
        case failure(Error)
    }

    private let outcome: Outcome
    private var count = 0
    private var callTimes: [Date] = []

    init(outcome: Outcome) {
        self.outcome = outcome
    }

    func performRefresh(refreshToken: String) async throws -> any TokenSetProtocol {
        count += 1
        callTimes.append(Date())
        
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
    
    func getCallTimes() -> [Date] {
        callTimes
    }
}
