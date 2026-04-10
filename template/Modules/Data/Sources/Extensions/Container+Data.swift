import FactoryKit
import Domain

extension Container {

    public var keychainManager: Factory<KeychainManagerProtocol> {
        self { KeychainManager() }.singleton
    }

    public var userDefaultsManager: Factory<UserDefaultsManagerProtocol> {
        self { UserDefaultsManager() }.singleton
    }

    public var remoteConfigSource: Factory<RemoteConfigSource> {
        self { InMemoryRemoteConfigSource() }.singleton
    }

    public var remoteConfigRepository: Factory<RemoteConfigRepository> {
        self { DefaultRemoteConfigRepository(source: self.remoteConfigSource()) }.singleton
    }

    public var loadStartupConfigUseCase: Factory<LoadStartupConfigUseCaseProtocol> {
        self { LoadStartupConfigUseCase(remoteConfigRepository: self.remoteConfigRepository()) }.singleton
    }

    public var featureFlagRepository: Factory<FeatureFlagRepository> {
        self { DefaultFeatureFlagRepository() }.singleton
    }

    public var sessionRepository: Factory<SessionRepositoryProtocol> {
        self { SessionRepository() }.singleton
    }
}
