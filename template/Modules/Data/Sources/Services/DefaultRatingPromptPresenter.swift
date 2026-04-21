//
//  DefaultRatingPromptPresenter.swift
//

import Domain
import StoreKit
import UIKit

// MARK: - DefaultRatingPromptPresenter

public final class DefaultRatingPromptPresenter: RatingPromptPresenterProtocol, @unchecked Sendable {

    private let storeReviewController: any StoreReviewControllerProtocol

    public convenience init() {
        self.init(storeReviewController: DefaultStoreReviewController())
    }

    init(storeReviewController: any StoreReviewControllerProtocol) {
        self.storeReviewController = storeReviewController
    }

    @MainActor
    public func show() async {
        await storeReviewController.requestReview()
    }
}

// MARK: - StoreReviewControllerProtocol

protocol StoreReviewControllerProtocol: Sendable {

    @MainActor
    func requestReview() async
}

struct DefaultStoreReviewController: StoreReviewControllerProtocol, Sendable {

    @MainActor
    func requestReview() async {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive })
        else {
            return
        }
        SKStoreReviewController.requestReview(in: windowScene)
    }
}
