//
//  DefaultRatingPromptPresenter.swift
//

import Domain
import StoreKit

// MARK: - DefaultRatingPromptPresenter

public final class DefaultRatingPromptPresenter: RatingPromptPresenterProtocol, @unchecked Sendable {

    private let storeReviewController: any StoreReviewControllerProtocol

    public init(storeReviewController: any StoreReviewControllerProtocol) {
        self.storeReviewController = storeReviewController
    }

    @MainActor
    public func show() async -> Bool {
        return await storeReviewController.requestReview()
    }
}
