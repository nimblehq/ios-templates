import Foundation
import Testing

@testable import Model

@Suite("TokenSetProtocol")
struct TokenSetProtocolTests {

    @Test("isExpired is false when the token set has no expiration date")
    func isExpiredIsFalseWhenTheTokenSetHasNoExpirationDate() {
        let tokenSet = StubTokenSet(expiresAt: nil)

        #expect(tokenSet.isExpired == false)
    }

    @Test("isExpired is true when the expiration date is in the past")
    func isExpiredIsTrueWhenTheExpirationDateIsInThePast() {
        let tokenSet = StubTokenSet(expiresAt: Date(timeIntervalSince1970: 0))

        #expect(tokenSet.isExpired == true)
    }
}

private struct StubTokenSet: TokenSetProtocol {
    let accessToken = "access-token"
    let refreshToken = "refresh-token"
    let expiresAt: Date?
}
