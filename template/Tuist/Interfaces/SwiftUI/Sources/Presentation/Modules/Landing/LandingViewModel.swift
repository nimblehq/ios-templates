import Data
import Domain
import FactoryKit
import Foundation
import Model
import SwiftUI

@MainActor
final class LandingViewModel: ObservableObject {

    enum State: Equatable {

        case loading
        case signedOut
        case signedIn
        case forceUpdateRequired
    }

    @Published private(set) var state: State = .loading
    private(set) var startupConfigLoadResult: StartupConfigLoadResult?

    @Injected(\.loadStartupConfigUseCase) private var loadStartupConfigUseCase: any LoadStartupConfigUseCaseProtocol
    @Injected(\.sessionRepository) private var sessionRepository: any SessionRepositoryProtocol
    @Injected(\.checkForceUpdateUseCase) private var checkForceUpdateUseCase: any CheckForceUpdateUseCaseProtocol
    @Injected(\.ratingPromptStorage) private var ratingPromptStorage: any RatingPromptStorageProtocol
    @Injected(\.requestRatingPromptUseCase) private var requestRatingPromptUseCase: any RequestRatingPromptUseCaseProtocol
    private var hasRestoredSession = false

    func restoreSessionIfNeeded() async {
        guard !hasRestoredSession else { return }

        ratingPromptStorage.recordAppLaunch()

        do {
            startupConfigLoadResult = try await loadStartupConfigUseCase()
        } catch is CancellationError {
            return
        } catch {
            startupConfigLoadResult = .usedLocalDefaults
        }

        hasRestoredSession = true

        guard !(await checkForceUpdateUseCase()) else {
            state = .forceUpdateRequired
            return
        }
        state = await sessionRepository.hasActiveSession() ? .signedIn : .signedOut

        if state == .signedIn {
            await tryShowRatingPrompt()
        }
    }

    func continueWithDemoSession() async {
        do {
            try await sessionRepository.save(tokenSet: DemoTokenSet())
            ratingPromptStorage.recordSignificantEvent()
            state = .signedIn
            await tryShowRatingPrompt()
        } catch {
            state = .signedOut
        }
    }

    func signOut() async {
        do {
            try await sessionRepository.clearSession()
            state = .signedOut
        } catch {}
    }

    private func tryShowRatingPrompt() async {
        _ = await requestRatingPromptUseCase(configuration: RatingPromptConfiguration())
    }
}

private struct DemoTokenSet: TokenSetProtocol {

    let accessToken = "demo-access-token"
    let refreshToken = "demo-refresh-token"
    let expiresAt: Date? = Date().addingTimeInterval(60 * 60 * 24 * 30)
}
