//
//  StoreReviewControllerProtocol.swift
//

public protocol StoreReviewControllerProtocol: Sendable {

    @MainActor
    func requestReview() async -> Bool
}
