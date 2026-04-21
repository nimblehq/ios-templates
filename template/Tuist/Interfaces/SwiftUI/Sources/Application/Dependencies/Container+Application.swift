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
        self { ShouldShowRatingPromptUseCase(storage: self.ratingPromptStorage()) }
    }

    var requestRatingPromptUseCase: Factory<RequestRatingPromptUseCaseProtocol> {
        self {
            RequestRatingPromptUseCase(
                storage: self.ratingPromptStorage(),
                shouldShowRatingPromptUseCase: self.shouldShowRatingPromptUseCase(),
                presenter: self.ratingPromptPresenter()
            )
        }
    }

    var ratingPromptPresenter: Factory<RatingPromptPresenterProtocol> {
        self { DefaultRatingPromptPresenter(storeReviewController: StoreReviewController()) }.singleton
    }
}
