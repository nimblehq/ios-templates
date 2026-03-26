import AuthTesting
import Nimble
import Quick

final class AuthServiceMockSpec: QuickSpec {

    override class func spec() {
        describe("AuthServiceMock") {
            var sut: AuthServiceMock!

            beforeEach {
                sut = AuthServiceMock()
            }

            describe("initial state") {
                it("has no current user") {
                    expect(sut.currentUser).to(beNil())
                }
            }

            describe("signIn") {
                context("when successful") {
                    it("sets current user with given email") {
                        waitUntil { done in
                            Task {
                                try? await sut.signIn(email: "user@example.com", password: "secret")
                                expect(sut.currentUser?.email).to(equal("user@example.com"))
                                expect(sut.signInCallCount).to(equal(1))
                                done()
                            }
                        }
                    }
                }

                context("when configured to throw") {
                    it("throws the configured error") {
                        sut.shouldThrowOnSignIn = .invalidEmail
                        waitUntil { done in
                            Task {
                                do {
                                    try await sut.signIn(email: "bad", password: "pass")
                                    fail("Expected error to be thrown")
                                } catch {
                                    expect(error as? AuthError).to(equal(.invalidEmail))
                                }
                                done()
                            }
                        }
                    }
                }
            }

            describe("signOut") {
                it("clears current user") {
                    waitUntil { done in
                        Task {
                            try? await sut.signIn(email: "user@example.com", password: "secret")
                            sut.signOut()
                            expect(sut.currentUser).to(beNil())
                            expect(sut.signOutCallCount).to(equal(1))
                            done()
                        }
                    }
                }
            }
        }
    }
}
