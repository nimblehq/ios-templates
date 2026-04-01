//
//  MockNetworkAPI.swift
//

@testable import Data

final class MockNetworkAPI: NetworkAPIProtocol, @unchecked Sendable {

    enum MockResult {

        case success(Any)
        case failure(Error)
    }

    var responses: [MockResult] = []
    private(set) var requestedConfigurations: [RequestConfiguration] = []

    func performRequest<T: Decodable & Sendable>(
        _ configuration: RequestConfiguration,
        for type: T.Type
    ) async throws -> T {
        requestedConfigurations.append(configuration)

        guard responses.isEmpty == false else {
            throw NetworkAPIError.generic
        }

        switch responses.removeFirst() {
        case let .success(value):
            guard let value = value as? T else {
                throw NetworkAPIError.generic
            }
            return value
        case let .failure(error):
            throw error
        }
    }
}
