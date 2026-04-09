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

    @Injected(\.sessionRepository) private var sessionRepository: any SessionRepositoryProtocol
    private var hasRestoredSession = false

    func restoreSessionIfNeeded() async {
        guard !hasRestoredSession else { return }

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

    let accessToken = "demo-access-token"
    let refreshToken = "demo-refresh-token"
    let expiresAt = Calendar.current.date(byAdding: .day, value: 30, to: Date())
}
