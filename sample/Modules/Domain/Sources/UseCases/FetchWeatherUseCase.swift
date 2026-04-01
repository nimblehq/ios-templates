//
//  FetchWeatherUseCase.swift
//

import Foundation

public protocol FetchWeatherUseCaseProtocol: Sendable {

    func execute(for query: String) async throws -> WeatherReport
}

public struct FetchWeatherUseCase: FetchWeatherUseCaseProtocol {

    private let repository: any WeatherRepositoryProtocol

    public init(repository: any WeatherRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(for query: String) async throws -> WeatherReport {
        // Normalize user input once here so the repository only deals with
        // validated city names.
        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard normalizedQuery.isEmpty == false else {
            throw WeatherLookupError.emptyQuery
        }

        return try await repository.fetchWeather(for: normalizedQuery)
    }
}
