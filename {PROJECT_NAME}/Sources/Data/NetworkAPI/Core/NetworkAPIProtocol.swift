//
//  NetworkAPIProtocol.swift
//

import Moya
import RxSwift

protocol NetworkAPIProtocol {

    func performRequest<T: Decodable>(_ configuration: TargetType, for type: T.Type) -> Single<T>
}

extension NetworkAPIProtocol {
    func request<T: Decodable>(
        provider: MoyaProvider<MultiTarget>,
        configuration: TargetType,
        decoder: JSONDecoder
    ) -> Single<T> {
        provider
            .rx
            .request(MultiTarget(configuration))
            .map(T.self, using: decoder)
    }
}
