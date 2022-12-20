//
//  NetworkAPIProtocol.swift
//

import Alamofire
import RxAlamofire
import RxSwift

protocol NetworkAPIProtocol {

    func performRequest<T: Decodable>(_ configuration: RequestConfiguration, for type: T.Type) -> Single<T>
}

extension NetworkAPIProtocol {

    func request<T: Decodable>(
        session: Session,
        configuration: RequestConfiguration,
        decoder: JSONDecoder
    ) -> Single<T> {
        return session.rx.request(
            configuration.method,
            configuration.url,
            parameters: configuration.parameters,
            encoding: configuration.encoding,
            headers: configuration.headers,
            interceptor: configuration.interceptor
        )
        .responseData()
        .flatMap { _, data -> Observable<T> in
            Observable.create { observer in
                do {
                    let decodable = try decoder.decode(T.self, from: data)
                    observer.on(.next(decodable))
                } catch {
                    observer.on(.error(error))
                }
                observer.on(.completed)
                return Disposables.create()
            }
        }
        .asSingle()
    }
}
