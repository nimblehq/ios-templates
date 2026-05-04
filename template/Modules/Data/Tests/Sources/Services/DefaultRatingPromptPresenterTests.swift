import Foundation
import Testing

@testable import Data
import Domain

@Suite("DefaultRatingPromptPresenter")
struct DefaultRatingPromptPresenterTests {

    @Test("calls requestReview on StoreReviewController when show is called and returns result")
    func callsRequestReviewOnStoreReviewControllerWhenShowIsCalledAndReturnsResult() async {
        let storeReviewController = SpyStoreReviewController()
        let presenter = DefaultRatingPromptPresenter(storeReviewController: storeReviewController)
        
        let result = await presenter.show()
        
        let callCount = await storeReviewController.requestReviewCallCount
        #expect(callCount == 1)
        #expect(result == true)
    }
    
    @Test("returns false when store review controller returns false")
    func returnsFalseWhenStoreReviewControllerReturnsFalse() async {
        let storeReviewController = SpyStoreReviewController(shouldReturnTrue: false)
        let presenter = DefaultRatingPromptPresenter(storeReviewController: storeReviewController)
        
        let result = await presenter.show()
        
        #expect(result == false)
    }
    
    @Test("multiple calls to show result in multiple requestReview calls")
    func multipleCallsToShowResultInMultipleRequestReviewCalls() async {
        let storeReviewController = SpyStoreReviewController()
        let presenter = DefaultRatingPromptPresenter(storeReviewController: storeReviewController)
        
        let result1 = await presenter.show()
        let result2 = await presenter.show()
        let result3 = await presenter.show()
        
        let callCount = await storeReviewController.requestReviewCallCount
        #expect(callCount == 3)
        #expect(result1 == true)
        #expect(result2 == true)
        #expect(result3 == true)
    }
}

// MARK: - Test Double

@MainActor
private final class SpyStoreReviewController: StoreReviewControllerProtocol, @unchecked Sendable {
    
    private(set) var requestReviewCallCount = 0
    private let shouldReturnTrue: Bool
    
    init(shouldReturnTrue: Bool = true) {
        self.shouldReturnTrue = shouldReturnTrue
    }
    
    func requestReview() async -> Bool {
        requestReviewCallCount += 1
        return shouldReturnTrue
    }
}
