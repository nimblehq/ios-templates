//
//  NetworkAPIProtocol.swift
//

import Moya
import RxSwift

protocol NetworkAPIProtocol {

    func performRequest<T: Decodable>(_ configuration: RequestConfiguration, for type: T.Type) -> Single<T>
}

extension NetworkAPIProtocol {
    func request<T: Decodable>(
        provider: MoyaProvider<RequestConfiguration>,
        configuration: RequestConfiguration
    ) -> Single<T> {
        provider.rx.request(configuration)
            .filterSuccessfulStatusAndRedirectCodes()
            .map(T.self)
    }
}
