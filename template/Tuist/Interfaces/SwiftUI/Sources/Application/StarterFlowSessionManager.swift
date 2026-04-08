import Data
import Domain
import FactoryKit
import Foundation
import Model

protocol StarterFlowSessionManaging: Sendable {
    func hasActiveSession() async -> Bool
    func activateDemoSession() async throws
    func clearSession() async throws
}

actor StarterFlowSessionManager: StarterFlowSessionManaging {
    private let sessionRepository: any SessionRepositoryProtocol

    init(sessionRepository: any SessionRepositoryProtocol = Container.shared.sessionRepository()) {
        self.sessionRepository = sessionRepository
    }

    func hasActiveSession() async -> Bool {
        await sessionRepository.hasActiveSession()
    }

    func activateDemoSession() async throws {
        try await sessionRepository.save(tokenSet: DemoTokenSet())
    }

    func clearSession() async throws {
        try await sessionRepository.clearSession()
    }
}

private struct DemoTokenSet: TokenSetProtocol {
    let accessToken = "demo-access-token"
    let refreshToken = "demo-refresh-token"
    let expiresAt = Calendar.current.date(byAdding: .day, value: 30, to: Date())
}
