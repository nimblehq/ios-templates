//
//  NetworkAPIProtocol.swift
//

import Alamofire

protocol NetworkAPIProtocol {

    func performRequest<T: Decodable>(
        _ configuration: RequestConfiguration,
        for type: T.Type
    ) async throws -> T
}

extension NetworkAPIProtocol {

    func request<T: Decodable>(
        session: Session,
        configuration: RequestConfiguration,
        decoder: JSONDecoder
    ) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            session.request(
                configuration.url,
                method: configuration.method,
                parameters: configuration.parameters,
                encoding: configuration.encoding,
                headers: configuration.headers,
                interceptor: configuration.interceptor
            )
            .response { response in
                switch response.result {
                case let .success(data):
                    do {
                        let decodedData = try decoder.decode(T.self, from: data ?? Data())
                        continuation.resume(returning: decodedData)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
