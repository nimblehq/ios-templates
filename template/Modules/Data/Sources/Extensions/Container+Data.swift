import Domain
import FactoryKit

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

    public var featureFlagRepository: Factory<FeatureFlagRepository> {
        self { DefaultFeatureFlagRepository() }.singleton
    }

    public var sessionRepository: Factory<SessionRepositoryProtocol> {
        self { SessionRepository() }.singleton
    }

    public var firebaseRemoteConfigSource: Factory<FirebaseRemoteConfigSource> {
        self { FirebaseRemoteConfigSource() }.singleton
    }

    public var remoteConfigRepository: Factory<RemoteConfigRepository> {
        self { DefaultRemoteConfigRepository(source: self.firebaseRemoteConfigSource()) }.singleton
    }

    /// Example AppConfig factory. Replace with your app-specific configuration.
    public var exampleAppConfig: Factory<AppConfig<ExampleAppConfiguration>> {
        self { createExampleAppConfig() }.singleton
    }
}
