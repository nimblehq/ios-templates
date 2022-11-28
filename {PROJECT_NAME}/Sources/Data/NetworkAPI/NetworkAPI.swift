//
//  NetworkAPI.swift
//

import Foundation
import Moya
import RxSwift

final class NetworkAPI: NetworkAPIProtocol {

    private let provider: MoyaProvider<RequestConfiguration>

    init(provider: MoyaProvider<RequestConfiguration> = MoyaProvider<RequestConfiguration>()) {
        self.provider = provider
    }

    func performRequest<T: Decodable>(_ configuration: RequestConfiguration, for type: T.Type) -> Single<T> {
        request(provider: provider, configuration: configuration)
    }
}
