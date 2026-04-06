import Domain
import KeychainAccess
import Model

// TODO: Make this as an actor & implement the detail to save token models to Keychain
final class SessionRepository: SessionRepositoryProtocol {

    func hasActiveSession() -> Bool {
        false
    }

    func currentTokenSet() -> (any TokenSetProtocol)? {
        nil
    }

    func save(tokenSet: any TokenSetProtocol) throws {
    }

    func clearSession() throws {
    }
}
