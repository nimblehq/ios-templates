import Analytics
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

    @Injected(\.analytics) private var analytics: AnalyticsProtocol
    @Injected(\.loadStartupConfigUseCase) private var loadStartupConfigUseCase: any LoadStartupConfigUseCaseProtocol
    @Injected(\.sessionRepository) private var sessionRepository: any SessionRepositoryProtocol
    @Injected(\.checkForceUpdateUseCase) private var checkForceUpdateUseCase: any CheckForceUpdateUseCaseProtocol
    private var hasRestoredSession = false

    func restoreSessionIfNeeded() async {
        guard !hasRestoredSession else { return }

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
    }

    func continueWithDemoSession() async {
        do {
            try await sessionRepository.save(tokenSet: DemoTokenSet())
            state = .signedIn
            
            // Track successful login event
            let loginEvent = UserLoginEvent(loginMethod: "demo", isSuccessful: true)
            analytics.trackEvent(loginEvent)
        } catch {
            state = .signedOut
            
            // Track failed login event
            let loginEvent = UserLoginEvent(loginMethod: "demo", isSuccessful: false)
            analytics.trackEvent(loginEvent)
        }
    }

    func signOut() async {
        do {
            try await sessionRepository.clearSession()
            state = .signedOut
        } catch {}
    }
}

private struct DemoTokenSet: TokenSetProtocol {

    let accessToken = "demo-access-token"
    let refreshToken = "demo-refresh-token"
    let expiresAt: Date? = Date().addingTimeInterval(60 * 60 * 24 * 30)
}
