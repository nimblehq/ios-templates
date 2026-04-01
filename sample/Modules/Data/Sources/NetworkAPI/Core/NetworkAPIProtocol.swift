//
//  NetworkAPIProtocol.swift
//

import Alamofire
import Foundation

protocol NetworkAPIProtocol: Sendable {

    func performRequest<T: Decodable & Sendable>(
        _ configuration: RequestConfiguration,
        for type: T.Type
    ) async throws -> T
}

extension NetworkAPIProtocol {

    func request<T: Decodable & Sendable>(
        session: Session,
        configuration: RequestConfiguration
    ) async throws -> T {
        do {
            return try await session.request(
                configuration.url,
                method: configuration.method,
                parameters: configuration.parameters,
                encoding: configuration.encoding,
                headers: configuration.headers,
                interceptor: configuration.interceptor
            )
            .serializingDecodable(T.self)
            .value
        } catch {
            if let afError = error as? AFError, afError.isExplicitlyCancelledError {
                throw CancellationError()
            }

            let nsError = error as NSError
            if nsError.domain == NSURLErrorDomain, nsError.code == NSURLErrorCancelled {
                throw CancellationError()
            }

            throw error
        }
    }
}
