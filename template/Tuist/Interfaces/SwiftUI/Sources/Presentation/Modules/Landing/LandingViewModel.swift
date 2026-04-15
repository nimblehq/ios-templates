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
    }

    @Published private(set) var state: State = .loading
    private(set) var startupConfigLoadResult: StartupConfigLoadResult?

    @Injected(\.loadStartupConfigUseCase) private var loadStartupConfigUseCase: any LoadStartupConfigUseCaseProtocol
    @Injected(\.sessionRepository) private var sessionRepository: any SessionRepositoryProtocol
    private var hasRestoredSession = false

    func restoreSessionIfNeeded() async {
        guard !hasRestoredSession else { return }

        do {
            startupConfigLoadResult = try await loadStartupConfigUseCase()
        } catch is CancellationError {
            return
        }

        hasRestoredSession = true
        state = await sessionRepository.hasActiveSession() ? .signedIn : .signedOut
    }

    func continueWithDemoSession() async {
        do {
            try await sessionRepository.save(tokenSet: DemoTokenSet())
            state = .signedIn
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
}

private struct DemoTokenSet: TokenSetProtocol {

    var accessToken: String { "demo-access-token" }
    var refreshToken: String { "demo-refresh-token" }
    var expiresAt: Date? { Date().addingTimeInterval(60 * 60 * 24 * 30) }
}
