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

    public var networkAPI: Factory<NetworkAPI> {
        self { NetworkAPI(authenticationInterceptor: self.authenticationInterceptor()) }
            .singleton
    }
}
