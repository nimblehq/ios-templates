import FactoryKit
import Foundation
import Testing

@testable import Data

@Suite("SessionRepository")
struct SessionRepositoryTests {

    @Test("reports no active session when no token set is stored")
    func reportsNoActiveSessionWhenNoTokenSetIsStored() async {
        let repository = makeRepository()
        defer { Container.shared.reset() }

        let result = await repository.hasActiveSession()

        #expect(result == false)
    }

    @Test("reports an active session when a token set is stored")
    func reportsAnActiveSessionWhenATokenSetIsStored() async throws {
        let repository = makeRepository()
        defer { Container.shared.reset() }

        try await repository.save(tokenSet: TokenSet(
            accessToken: "access",
            refreshToken: "refresh",
            expiresAt: nil
        ))

        let result = await repository.hasActiveSession()

        #expect(result == true)
    }

    @Test("returns nil when no token set is stored")
    func returnsNilWhenNoTokenSetIsStored() async {
        let repository = makeRepository()
        defer { Container.shared.reset() }

        let result = await repository.currentTokenSet()

        #expect(result == nil)
    }

    @Test("returns the stored token set values")
    func returnsTheStoredTokenSetValues() async throws {
        let repository = makeRepository()
        defer { Container.shared.reset() }

        let expiresAt = Date(timeIntervalSince1970: 1_000_000)
        try await repository.save(tokenSet: TokenSet(
            accessToken: "test-access-token",
            refreshToken: "test-refresh-token",
            expiresAt: expiresAt
        ))

        let result = await repository.currentTokenSet()

        #expect(result?.accessToken == "test-access-token")
        #expect(result?.refreshToken == "test-refresh-token")
        #expect(result?.expiresAt == expiresAt)
    }

    @Test("overwrites the previously stored token set when saving again")
    func overwritesThePreviouslyStoredTokenSetWhenSavingAgain() async throws {
        let repository = makeRepository()
        defer { Container.shared.reset() }

        try await repository.save(tokenSet: TokenSet(
            accessToken: "first-access",
            refreshToken: "first-refresh",
            expiresAt: nil
        ))
        try await repository.save(tokenSet: TokenSet(
            accessToken: "second-access",
            refreshToken: "second-refresh",
            expiresAt: nil
        ))

        let result = await repository.currentTokenSet()

        #expect(result?.accessToken == "second-access")
        #expect(result?.refreshToken == "second-refresh")
    }

    @Test("clears the stored session")
    func clearsTheStoredSession() async throws {
        let repository = makeRepository()
        defer { Container.shared.reset() }

        try await repository.save(tokenSet: TokenSet(
            accessToken: "access",
            refreshToken: "refresh",
            expiresAt: nil
        ))

        try await repository.clearSession()

        let hasSession = await repository.hasActiveSession()
        let tokenSet = await repository.currentTokenSet()

        #expect(hasSession == false)
        #expect(tokenSet == nil)
    }

    private func makeRepository() -> SessionRepository {
        let keychainManager = KeychainManagerMock()
        Container.shared.keychainManager.register { [keychainManager] in keychainManager }
        return SessionRepository()
    }
}
