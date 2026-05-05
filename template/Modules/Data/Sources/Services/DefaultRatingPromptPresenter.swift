//
//  DefaultRatingPromptPresenter.swift
//

import Domain
import StoreKit

// MARK: - DefaultRatingPromptPresenter

public actor DefaultRatingPromptPresenter: RatingPromptPresenterProtocol {

    private let storeReviewController: any StoreReviewControllerProtocol

    public init(storeReviewController: any StoreReviewControllerProtocol) {
        self.storeReviewController = storeReviewController
    }

    public func show() async -> Bool {
        return await storeReviewController.requestReview()
    }
}
