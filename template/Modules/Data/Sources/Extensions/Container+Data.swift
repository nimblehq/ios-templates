import FactoryKit

extension Container {

    public var keychainManager: Factory<KeychainManagerProtocol> {
        self { KeychainManager() }.singleton
    }

    public var userDefaultsManager: Factory<UserDefaultsManagerProtocol> {
        self { UserDefaultsManager() }.singleton
    }
}
