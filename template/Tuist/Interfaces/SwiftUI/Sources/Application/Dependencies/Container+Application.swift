import Data
import Domain
import FactoryKit

extension Container {

    var loadStartupConfigUseCase: Factory<LoadStartupConfigUseCaseProtocol> {
        self { LoadStartupConfigUseCase(remoteConfigRepository: self.remoteConfigRepository()) }
    }

    var checkForceUpdateUseCase: Factory<CheckForceUpdateUseCaseProtocol> {
        self { CheckForceUpdateUseCase(remoteConfigRepository: self.remoteConfigRepository()) }
    }
}
