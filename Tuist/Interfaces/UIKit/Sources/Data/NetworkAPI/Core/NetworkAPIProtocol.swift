//
//  NetworkAPIProtocol.swift
//

import Alamofire
import Combine

protocol NetworkAPIProtocol {

    func performRequest<T: Decodable>(
        _ configuration: RequestConfiguration,
        for type: T.Type
    ) -> AnyPublisher<T, AFError>
}

extension NetworkAPIProtocol {

    func request<T: Decodable>(
        session: Session,
        configuration: RequestConfiguration,
        decoder: JSONDecoder
    ) -> AnyPublisher<T, AFError> {
        return session.request(
            configuration.url,
            method: configuration.method,
            parameters: configuration.parameters,
            encoding: configuration.encoding,
            headers: configuration.headers,
            interceptor: configuration.interceptor
        )
        .publishDecodable(type: T.self, decoder: decoder)
        .value()
    }
}
