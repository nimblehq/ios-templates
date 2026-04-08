import Domain
import FactoryKit
import Model

actor SessionRepository: SessionRepositoryProtocol {

    private let keychainManager: KeychainManagerProtocol

    init(keychainManager: KeychainManagerProtocol = Container.shared.keychainManager()) {
        self.keychainManager = keychainManager
    }

    func hasActiveSession() -> Bool {
        let tokenSet: TokenSet? = try? keychainManager.get(.userToken)
        return tokenSet != nil
    }

    func currentTokenSet() -> (any TokenSetProtocol)? {
        try? keychainManager.get(.userToken) as TokenSet?
    }

    func save(tokenSet: any TokenSetProtocol) throws {
        let storable = TokenSet(
            accessToken: tokenSet.accessToken,
            refreshToken: tokenSet.refreshToken,
            expiresAt: tokenSet.expiresAt
        )
        try keychainManager.set(storable, for: .userToken)
    }

    func clearSession() throws {
        try keychainManager.remove(.userToken)
    }
}
