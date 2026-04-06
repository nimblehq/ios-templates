import Foundation
import Model

/// An internal struct for Data layer to store in Keychain and process the data
struct TokenSet: TokenSetProtocol, Codable {

    let accessToken: String
    let refreshToken: String
    let expiresAt: Date?
    let tokenType: String?
}
