//
//  NetworkAPIProtocol.swift
//

import Alamofire
import Foundation

protocol NetworkAPIProtocol {

    func performRequest<T: Decodable & Sendable>(
        _ configuration: RequestConfiguration,
        for type: T.Type
    ) async throws -> T

    /// Authenticated API calls. Uses an Alamofire `Session` configured with `AuthenticationInterceptor` when provided at initialization.
    func performAuthenticatedRequest<T: Decodable & Sendable>(
        _ configuration: RequestConfiguration,
        for type: T.Type
    ) async throws -> T
}

extension NetworkAPIProtocol {

    func performAuthenticatedRequest<T: Decodable & Sendable>(
        _ configuration: RequestConfiguration,
        for type: T.Type
    ) async throws -> T {
        try await performRequest(configuration, for: type)
    }

    func request<T: Decodable & Sendable>(
        session: Session,
        configuration: RequestConfiguration,
        decoder: JSONDecoder
    ) async throws -> T {
        try await session.request(
            configuration.url,
            method: configuration.method,
            parameters: configuration.parameters,
            encoding: configuration.encoding,
            headers: configuration.headers,
            interceptor: configuration.interceptor
        )
        .serializingDecodable(T.self)
        .value
    }
}
