import Domain
import KeychainAccess

// TODO: Make this as an actor
final class SessionRepository: SessionRepositoryProtocol {

    private enum Key {
        static let tokenSet = "auth_token_set"
    }

    private let keychain: Keychain
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(keychain: Keychain) {
        self.keychain = keychain
    }

    func hasActiveSession() -> Bool {
        currentTokenSet() != nil
    }

    func currentTokenSet() -> (any TokenSetProtocol)? {
        guard let data = try? keychain.getData(Key.tokenSet) else { return nil }
        return try? decoder.decode(TokenSet.self, from: data)
    }

    func save(tokenSet: any TokenSetProtocol) throws {
        let token = TokenSet(
            accessToken: tokenSet.accessToken,
            refreshToken: tokenSet.refreshToken,
            expiresAt: tokenSet.expiresAt,
            tokenType: tokenSet.tokenType
        )
        let data = try encoder.encode(token)
        try keychain.set(data, key: Key.tokenSet)
    }

    func clearSession() throws {
        try keychain.remove(Key.tokenSet)
    }
}
