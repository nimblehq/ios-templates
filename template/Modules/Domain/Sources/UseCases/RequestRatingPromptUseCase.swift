//
//  RequestRatingPromptUseCase.swift
//

import Foundation

public protocol RequestRatingPromptUseCaseProtocol: Sendable {

    /// Evaluates eligibility and, if eligible, shows the rating prompt.
    /// - Returns: `true` if the prompt was shown.
    @MainActor
    func callAsFunction(configuration: RatingPromptConfiguration) async -> Bool
}

public struct RequestRatingPromptUseCase: RequestRatingPromptUseCaseProtocol {

    private let storage: any RatingPromptStorageProtocol
    private let shouldShowRatingPromptUseCase: any ShouldShowRatingPromptUseCaseProtocol
    private let presenter: any RatingPromptPresenterProtocol
    private let currentVersion: @Sendable () -> String

    public init(
        storage: any RatingPromptStorageProtocol,
        shouldShowRatingPromptUseCase: any ShouldShowRatingPromptUseCaseProtocol,
        presenter: any RatingPromptPresenterProtocol,
        currentVersion: @Sendable @escaping () -> String = {
            Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        }
    ) {
        self.storage = storage
        self.shouldShowRatingPromptUseCase = shouldShowRatingPromptUseCase
        self.presenter = presenter
        self.currentVersion = currentVersion
    }

    @MainActor
    public func callAsFunction(configuration: RatingPromptConfiguration) async -> Bool {
        guard await shouldShowRatingPromptUseCase(configuration: configuration) else { return false }

        let didRequestPrompt = await presenter.show()
        guard didRequestPrompt else { return false }

        await storage.recordPromptShown(for: currentVersion())

        if configuration.resetCounterAfterPrompt {
            await storage.resetCounters()
        }

        return true
    }
}
