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

    var shouldShowRatingPromptUseCase: Factory<ShouldShowRatingPromptUseCaseProtocol> {
        self { ShouldShowRatingPromptUseCase(repository: self.ratingPromptRepository()) }
    }

    var requestRatingPromptUseCase: Factory<RequestRatingPromptUseCaseProtocol> {
        self {
            RequestRatingPromptUseCase(
                repository: self.ratingPromptRepository(),
                shouldShowRatingPromptUseCase: self.shouldShowRatingPromptUseCase(),
                presenter: self.ratingPromptPresenter()
            )
        }
    }

    var ratingPromptPresenter: Factory<RatingPromptPresenterProtocol> {
        self { DefaultRatingPromptPresenter(storeReviewController: StoreReviewController()) }.singleton
    }
}
