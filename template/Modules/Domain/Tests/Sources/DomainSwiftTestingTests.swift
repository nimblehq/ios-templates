//
//  DomainSwiftTestingTests.swift
//

import Testing

@testable import Domain

@Suite("Domain")
struct DomainSwiftTestingTests {

    @Test("UseCaseFactoryProtocol is accessible from the Domain module")
    func useCaseFactoryProtocolIsAccessible() {
        _ = UseCaseFactoryProtocol.self
    }
}

