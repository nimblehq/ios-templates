import FactoryKit
import Domain

extension Container {

    public var keychainManager: Factory<KeychainManagerProtocol> {
        self { KeychainManager() }.singleton
    }

    public var userDefaultsManager: Factory<UserDefaultsManagerProtocol> {
        self { UserDefaultsManager() }.singleton
    }

    public var sessionRepository: Factory<SessionRepositoryProtocol> {
        self { SessionRepository() }.singleton
    }
}
