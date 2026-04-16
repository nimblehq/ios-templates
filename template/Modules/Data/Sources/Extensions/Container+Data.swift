import Domain
import FactoryKit

extension Container {

    public var keychainManager: Factory<KeychainManagerProtocol> {
        self { KeychainManager() }.singleton
    }

    public var userDefaultsManager: Factory<UserDefaultsManagerProtocol> {
        self { UserDefaultsManager() }.singleton
    }

    public var configSource: Factory<ConfigSource> {
        self { InMemoryConfigSource() }.singleton
    }

    public var remoteConfigRepository: Factory<RemoteConfigRepository> {
        self { DefaultRemoteConfigRepository(source: self.configSource()) }.singleton
    }

    public var featureFlagRepository: Factory<FeatureFlagRepository> {
        self { DefaultFeatureFlagRepository() }.singleton
    }

    public var sessionRepository: Factory<SessionRepositoryProtocol> {
        self { SessionRepository() }.singleton
    }
}
