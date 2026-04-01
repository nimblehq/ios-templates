//
//  DomainSwiftTestingTests.swift
//

import Testing

@testable import Domain

@Suite("Domain")
struct DomainSwiftTestingTests {

    @Test("FetchWeatherUseCaseProtocol metatype is accessible from the Domain module")
    func fetchWeatherUseCaseProtocolMetatypeIsAccessible() {
        _ = FetchWeatherUseCaseProtocol.self
    }
}
