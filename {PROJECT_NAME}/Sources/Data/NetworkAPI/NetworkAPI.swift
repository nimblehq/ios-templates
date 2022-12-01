//
//  NetworkAPI.swift
//

import Foundation
import Moya
import RxSwift

final class NetworkAPI: NetworkAPIProtocol {

    private let provider: MoyaProvider<MultiTarget>

    init(provider: MoyaProvider<MultiTarget> = MoyaProvider<MultiTarget>()) {
        self.provider = provider
    }

    func performRequest<T: Decodable>(_ configuration: TargetType, for type: T.Type) -> Single<T> {
        request(provider: provider, configuration: configuration)
    }
}
