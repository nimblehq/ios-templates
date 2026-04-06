public protocol SessionRepositoryProtocol: Sendable {

    func hasActiveSession() -> Bool
    func currentTokenSet() -> (any TokenSetProtocol)?
    func save(tokenSet: any TokenSetProtocol) throws
    func clearSession() throws
}
