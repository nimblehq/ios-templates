//
//  NetworkAPI.swift
//

import Alamofire
import Foundation
import RxSwift

final class NetworkAPI: NetworkAPIProtocol {

    private let decoder: JSONDecoder

    init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
    }

    func performRequest<T: Decodable>(_ configuration: RequestConfiguration, for type: T.Type) -> Single<T> {
        request(
            session: Session(),
            configuration: configuration,
            decoder: decoder
        )
    }
}
