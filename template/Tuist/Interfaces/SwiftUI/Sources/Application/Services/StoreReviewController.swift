//
//  StoreReviewController.swift
//

import Domain
import StoreKit
import UIKit

final class StoreReviewController: StoreReviewControllerProtocol, Sendable {

    @MainActor
    func requestReview() async -> Bool {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive })
        else {
            return false
        }
        SKStoreReviewController.requestReview(in: windowScene)
        return true
    }
}
