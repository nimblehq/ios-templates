//
//  FirebaseRemoteConfigSourceTests.swift
//

import Domain
import FirebaseRemoteConfig
import Foundation
import Testing

@testable import Data

@Suite("FirebaseRemoteConfigSource")
struct FirebaseRemoteConfigSourceTests {

    @Test("returns nil for missing keys")
    func returnsNilForMissingKeys() async {
        let mockRemoteConfig = MockRemoteConfig()
        let source = FirebaseRemoteConfigSource(remoteConfig: mockRemoteConfig)
        
        let value = await source.value(forKey: "missing_key")
        
        #expect(value == nil)
    }

    @Test("returns bool value for boolean strings")
    func returnsBoolForBooleanStrings() async {
        let mockRemoteConfig = MockRemoteConfig()
        mockRemoteConfig.setMockValue("true", forKey: "bool_key")
        let source = FirebaseRemoteConfigSource(remoteConfig: mockRemoteConfig)
        
        let value = await source.value(forKey: "bool_key")
        
        #expect(value == .bool(true))
    }

    @Test("returns int value for integer strings")
    func returnsIntForIntegerStrings() async {
        let mockRemoteConfig = MockRemoteConfig()
        mockRemoteConfig.setMockValue("42", forKey: "int_key")
        let source = FirebaseRemoteConfigSource(remoteConfig: mockRemoteConfig)
        
        let value = await source.value(forKey: "int_key")
        
        #expect(value == .int(42))
    }

    @Test("returns double value for decimal strings")
    func returnsDoubleForDecimalStrings() async {
        let mockRemoteConfig = MockRemoteConfig()
        mockRemoteConfig.setMockValue("3.14", forKey: "double_key")
        let source = FirebaseRemoteConfigSource(remoteConfig: mockRemoteConfig)
        
        let value = await source.value(forKey: "double_key")
        
        #expect(value == .double(3.14))
    }

    @Test("returns string value for text")
    func returnsStringForText() async {
        let mockRemoteConfig = MockRemoteConfig()
        mockRemoteConfig.setMockValue("hello world", forKey: "string_key")
        let source = FirebaseRemoteConfigSource(remoteConfig: mockRemoteConfig)
        
        let value = await source.value(forKey: "string_key")
        
        #expect(value == .string("hello world"))
    }

    @Test("refresh calls fetchAndActivate")
    func refreshCallsFetchAndActivate() async throws {
        let mockRemoteConfig = MockRemoteConfig()
        let source = FirebaseRemoteConfigSource(remoteConfig: mockRemoteConfig)
        
        try await source.refresh()
        
        #expect(mockRemoteConfig.fetchAndActivateCalled)
    }

    @Test("refresh throws on Firebase error")
    func refreshThrowsOnFirebaseError() async {
        let mockRemoteConfig = MockRemoteConfig()
        mockRemoteConfig.shouldFailFetchAndActivate = true
        let source = FirebaseRemoteConfigSource(remoteConfig: mockRemoteConfig)
        
        var didThrow = false
        do {
            try await source.refresh()
        } catch {
            didThrow = true
        }
        
        #expect(didThrow)
    }
}

// MARK: - Mock RemoteConfig

private class MockRemoteConfig: RemoteConfig {
    
    private var mockValues: [String: String] = [:]
    var fetchAndActivateCalled = false
    var shouldFailFetchAndActivate = false
    
    func setMockValue(_ value: String, forKey key: String) {
        mockValues[key] = value
    }
    
    override subscript(key: String) -> RemoteConfigValue {
        if let value = mockValues[key] {
            return MockRemoteConfigValue(stringValue: value)
        }
        return MockRemoteConfigValue(stringValue: "")
    }
    
    override func fetchAndActivate(completionHandler: ((RemoteConfigFetchAndActivateStatus, (any Error)?) -> Void)? = nil) {
        fetchAndActivateCalled = true
        DispatchQueue.main.async {
            if self.shouldFailFetchAndActivate {
                completionHandler?(.error, NSError(domain: "TestError", code: -1))
            } else {
                completionHandler?(.successFetchedFromRemote, nil)
            }
        }
    }
}

private class MockRemoteConfigValue: RemoteConfigValue {
    
    private let _stringValue: String
    
    init(stringValue: String) {
        self._stringValue = stringValue
    }
    
    override var stringValue: String { _stringValue }
    override var numberValue: NSNumber { NSNumber(value: 0) }
    override var boolValue: Bool { false }
    override var dataValue: Data { _stringValue.data(using: .utf8) ?? Data() }
    override var source: RemoteConfigSource { _stringValue.isEmpty ? .static : .remote }
}