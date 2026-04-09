//
//  SessionRepositorySpec.swift
//

import FactoryKit
import Foundation
import Nimble
import Quick

@testable import Data

final class SessionRepositorySpec: AsyncSpec {

    // swiftlint:disable:next function_body_length
    override class func spec() {

        // swiftlint:disable closure_body_length
        describe("a SessionRepository") {

            var keychainManager: KeychainManagerMock!
            var repository: SessionRepository!

            beforeEach {
                keychainManager = KeychainManagerMock()
                Container.shared.keychainManager.register { [keychainManager] in keychainManager! }
                repository = SessionRepository()
            }

            afterEach {
                Container.shared.reset()
            }

            describe("its hasActiveSession") {

                context("when no session is saved") {

                    it("returns false") {
                        let result = await repository.hasActiveSession()
                        expect(result) == false
                    }
                }

                context("when a session is saved") {

                    beforeEach {
                        let tokenSet = TokenSet(
                            accessToken: "access",
                            refreshToken: "refresh",
                            expiresAt: nil
                        )
                        try await repository.save(tokenSet: tokenSet)
                    }

                    it("returns true") {
                        let result = await repository.hasActiveSession()
                        expect(result) == true
                    }
                }
            }

            describe("its currentTokenSet") {

                context("when no session is saved") {

                    it("returns nil") {
                        let result = await repository.currentTokenSet()
                        expect(result).to(beNil())
                    }
                }

                context("when a session is saved") {

                    let expiresAt = Date(timeIntervalSince1970: 1_000_000)

                    beforeEach {
                        let tokenSet = TokenSet(
                            accessToken: "test-access-token",
                            refreshToken: "test-refresh-token",
                            expiresAt: expiresAt
                        )
                        try await repository.save(tokenSet: tokenSet)
                    }

                    it("returns the saved access token") {
                        let result = await repository.currentTokenSet()
                        expect(result?.accessToken) == "test-access-token"
                    }

                    it("returns the saved refresh token") {
                        let result = await repository.currentTokenSet()
                        expect(result?.refreshToken) == "test-refresh-token"
                    }

                    it("returns the saved expiration date") {
                        let result = await repository.currentTokenSet()
                        expect(result?.expiresAt) == expiresAt
                    }
                }
            }

            describe("its save") {

                it("overwrites the previous token set") {
                    let first = TokenSet(
                        accessToken: "first-access",
                        refreshToken: "first-refresh",
                        expiresAt: nil,
                    )
                    try await repository.save(tokenSet: first)

                    let second = TokenSet(
                        accessToken: "second-access",
                        refreshToken: "second-refresh",
                        expiresAt: nil,
                    )
                    try await repository.save(tokenSet: second)

                    let result = await repository.currentTokenSet()
                    expect(result?.accessToken) == "second-access"
                    expect(result?.refreshToken) == "second-refresh"
                }
            }

            describe("its clearSession") {

                beforeEach {
                    let tokenSet = TokenSet(
                        accessToken: "access",
                        refreshToken: "refresh",
                        expiresAt: nil,
                    )
                    try await repository.save(tokenSet: tokenSet)
                }

                it("removes the active session") {
                    try await repository.clearSession()

                    let hasSession = await repository.hasActiveSession()
                    expect(hasSession) == false
                }

                it("returns nil for currentTokenSet") {
                    try await repository.clearSession()

                    let tokenSet = await repository.currentTokenSet()
                    expect(tokenSet).to(beNil())
                }
            }
        }
        // swiftlint:enable closure_body_length
    }
}
