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

    public var tokenRefreshCoordinator: Factory<TokenRefreshCoordinator> {
        self {
            TokenRefreshCoordinator(
                sessionRepository: self.sessionRepository(),
                refreshClient: DefaultRefreshTokenClient()
            )
        }
        .singleton
    }

    public var authenticationInterceptor: Factory<AuthenticationInterceptor> {
        self { AuthenticationInterceptor(coordinator: self.tokenRefreshCoordinator()) }
            .singleton
    }

    var networkAPI: Factory<NetworkAPI> {
        self { NetworkAPI(authenticationInterceptor: self.authenticationInterceptor()) }
            .singleton
    }
}
