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
        // TODO: Replace with actual auth provider endpoint
        let configuration = <#RequestConfiguration#>
        let response: TokenSet = try await networkAPI.performRequest(configuration, for: TokenSet.self)
        return response
    }

    func logOut(accessToken: String) async throws {
        // TODO: Replace with actual auth provider endpoint
        let configuration = <#RequestConfiguration#>
        _ = try await networkAPI.performRequest(configuration, for: EmptyResponse.self)
    }

    func refreshToken(_ refreshToken: String) async throws -> any TokenSetProtocol {
        // TODO: Replace with actual auth provider endpoint
        let configuration = <#RequestConfiguration#>
        let response: TokenSet = try await networkAPI.performRequest(configuration, for: TokenSet.self)
        return response
    }
}

private struct EmptyResponse: Decodable, Sendable {}
