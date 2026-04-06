import Model

public protocol AuthRepositoryProtocol: Sendable {

    func logIn(username: String, password: String) async throws -> any TokenSetProtocol
    func logOut(accessToken: String) async throws
    func refreshToken(_ refreshToken: String) async throws -> any TokenSetProtocol
}
