//
//  NetworkAPI.swift
//

import Alamofire
import Foundation

struct NetworkAPI: NetworkAPIProtocol, @unchecked Sendable {

    private let session: Session

    init(session: Session = Session()) {
        self.session = session
    }

    func performRequest<T: Decodable & Sendable>(
        _ configuration: RequestConfiguration,
        for type: T.Type
    ) async throws -> T {
        try await request(
            session: session,
            configuration: configuration
        )
    }
}
