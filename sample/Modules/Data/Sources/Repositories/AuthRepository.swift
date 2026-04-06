//
//  AuthRepository.swift
//

import Domain
import Model

final class AuthRepository: AuthRepositoryProtocol {

    private let networkAPI: NetworkAPIProtocol

    init(networkAPI: NetworkAPIProtocol) {
        self.networkAPI = networkAPI
    }

    func logIn(username: String, password: String) async throws -> any TokenSetProtocol {
        let configuration = AuthRequestConfiguration.logIn(username: username, password: password)
        let response: TokenSet = try await networkAPI.performRequest(configuration, for: TokenSet.self)
        return response
    }

    func logOut(accessToken: String) async throws {
        let configuration = AuthRequestConfiguration.logOut(accessToken: accessToken)
        _ = try await networkAPI.performRequest(configuration, for: EmptyResponse.self)
    }

    func refreshToken(_ refreshToken: String) async throws -> any TokenSetProtocol {
        let configuration = AuthRequestConfiguration.refreshToken(refreshToken)
        let response: TokenSet = try await networkAPI.performRequest(configuration, for: TokenSet.self)
        return response
    }
}

private struct EmptyResponse: Decodable, Sendable {}
