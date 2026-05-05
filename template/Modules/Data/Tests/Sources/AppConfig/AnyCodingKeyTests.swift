//
//  AnyCodingKeyTests.swift
//

import Foundation
import Testing

@testable import Data

@Suite("AnyCodingKey")
struct AnyCodingKeyTests {

    @Test("initializes with string value")
    func initializesWithStringValue() {
        let key = AnyCodingKey(stringValue: "test_key")
        
        #expect(key.stringValue == "test_key")
        #expect(key.intValue == nil)
    }

    @Test("initializes with integer value")
    func initializesWithIntegerValue() {
        let key = AnyCodingKey(intValue: 42)
        
        #expect(key.stringValue == "42")
        #expect(key.intValue == 42)
    }

    @Test("initializes from another CodingKey with string value")
    func initializesFromCodingKeyWithStringValue() {
        enum TestKey: String, CodingKey {
            case example = "example_key"
        }
        
        let key = AnyCodingKey(TestKey.example)
        
        #expect(key.stringValue == "example_key")
        #expect(key.intValue == nil)
    }

    @Test("initializes from another CodingKey with integer value")
    func initializesFromCodingKeyWithIntegerValue() {
        enum TestKey: Int, CodingKey {
            case first = 1
            
            var stringValue: String { "\(rawValue)" }
            var intValue: Int? { rawValue }
            
            init?(stringValue: String) {
                guard let int = Int(stringValue) else { return nil }
                self.init(rawValue: int)
            }
            
            init?(intValue: Int) {
                self.init(rawValue: intValue)
            }
        }
        
        let key = AnyCodingKey(TestKey.first)
        
        #expect(key.stringValue == "1")
        #expect(key.intValue == 1)
    }

    @Test("conforms to Hashable")
    func conformsToHashable() {
        let key1 = AnyCodingKey(stringValue: "same")
        let key2 = AnyCodingKey(stringValue: "same")
        let key3 = AnyCodingKey(stringValue: "different")
        
        #expect(key1 == key2)
        #expect(key1 != key3)
        #expect(key1.hashValue == key2.hashValue)
    }
}