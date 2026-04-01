//
//  WeatherRepositoryProtocol.swift
//

public protocol WeatherRepositoryProtocol: Sendable {

    func fetchWeather(for query: String) async throws -> WeatherReport
}
