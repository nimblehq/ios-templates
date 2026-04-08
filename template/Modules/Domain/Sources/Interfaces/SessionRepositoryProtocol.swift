import Model

public protocol SessionRepositoryProtocol: Sendable {

    func hasActiveSession() async -> Bool
    func currentTokenSet() async -> (any TokenSetProtocol)?
    func save(tokenSet: any TokenSetProtocol) async throws
    func clearSession() async throws
}
