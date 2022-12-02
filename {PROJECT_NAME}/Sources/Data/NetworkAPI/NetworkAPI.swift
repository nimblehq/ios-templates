//
//  NetworkAPI.swift
//

import Foundation
import Moya
import RxSwift

final class NetworkAPI: NetworkAPIProtocol {

    private let provider: MoyaProvider<MultiTarget>
    private let decoder: JSONDecoder

    init(
        provider: MoyaProvider<MultiTarget> = MoyaProvider<MultiTarget>(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.provider = provider
        self.decoder = decoder
    }

    func performRequest<T: Decodable>(_ configuration: TargetType, for type: T.Type) -> Single<T> {
        request(provider: provider, configuration: configuration, decoder: decoder)
    }
}
