//
//  DomainSwiftTestingTests.swift
//

import Testing

@testable import Domain

@Suite("Domain")
struct DomainSwiftTestingTests {

    @Test("UseCaseFactoryProtocol metatype is accessible from the Domain module")
    func useCaseFactoryProtocolMetatypeIsAccessible() {
        _ = UseCaseFactoryProtocol.self
    }
}
