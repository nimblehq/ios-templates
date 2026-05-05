import Analytics
import Data
import Domain
import FactoryKit

extension Container {

    var analytics: Factory<AnalyticsProtocol> {
        self { Analytics.shared }.singleton
    }

    var loadStartupConfigUseCase: Factory<LoadStartupConfigUseCaseProtocol> {
        self { LoadStartupConfigUseCase(remoteConfigRepository: self.remoteConfigRepository()) }
    }

    var checkForceUpdateUseCase: Factory<CheckForceUpdateUseCaseProtocol> {
        self { CheckForceUpdateUseCase(remoteConfigRepository: self.remoteConfigRepository()) }
    }
}
