//
//  NetworkAPI.swift
//

import Foundation
import Alamofire
import RxSwift

final class NetworkAPI: NetworkAPIProtocol {

    private let decoder: JSONDecoder

    init(decoder: JSONDecoder = JSONAPIDecoder.default) {
        self.decoder = decoder
    }

    func performRequest<T: Decodable>(_ configuration: RequestConfiguration, for type: T.Type) -> Single<T> {
        request(
            configuration: configuration,
            decoder: decoder
        )
    }
}
