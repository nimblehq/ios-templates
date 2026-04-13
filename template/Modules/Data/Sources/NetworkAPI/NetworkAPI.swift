//
//  NetworkAPI.swift
//

import Alamofire
import Foundation

final class NetworkAPI: NetworkAPIProtocol {

    private let decoder: JSONDecoder
    private let unauthenticatedSession: Session
    private let authenticatedSession: Session

    init(
        decoder: JSONDecoder = JSONDecoder(),
        authenticationInterceptor: AuthenticationInterceptor? = nil
    ) {
        self.decoder = decoder
        let plainSession = Session()
        self.unauthenticatedSession = plainSession
        if let authenticationInterceptor {
            self.authenticatedSession = Session(interceptor: authenticationInterceptor)
        } else {
            self.authenticatedSession = plainSession
        }
    }

    func performRequest<T: Decodable & Sendable>(
        _ configuration: RequestConfiguration,
        for type: T.Type
    ) async throws -> T {
        try await request(
            session: unauthenticatedSession,
            configuration: configuration,
            decoder: decoder
        )
    }

    func performAuthenticatedRequest<T: Decodable & Sendable>(
        _ configuration: RequestConfiguration,
        for type: T.Type
    ) async throws -> T {
        try await request(
            session: authenticatedSession,
            configuration: configuration,
            decoder: decoder
        )
    }
}
