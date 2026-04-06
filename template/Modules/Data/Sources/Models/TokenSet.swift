import Domain
import Foundation

struct TokenSet: TokenSetProtocol, Codable {

    let accessToken: String
    let refreshToken: String
    let expiresAt: Date?
    let tokenType: String?

    init(
        accessToken: String,
        refreshToken: String,
        expiresAt: Date? = nil,
        tokenType: String? = nil
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresAt = expiresAt
        self.tokenType = tokenType
    }
}
