//
//  AppDefaultConfigTests.swift
//

import Foundation
import Testing

@testable import Data

@Suite("AppDefaultConfig")
struct AppDefaultConfigTests {

    @Test("initializes with empty configs")
    func initializesWithEmptyConfigs() {
        let config = AppDefaultConfig()
        
        #expect(config.configs.isEmpty)
    }

    @Test("initializes with provided configs")
    func initializesWithProvidedConfigs() {
        let key = AnyCodingKey(stringValue: "test")
        let configs = [key: "value" as any Encodable]
        let config = AppDefaultConfig(configs: configs)
        
        #expect(config.configs.count == 1)
        #expect(config.configs[key] as? String == "value")
    }

    @Test("builds from string dictionary")
    func buildsFromStringDictionary() {
        let stringConfigs = [
            "flag": true,
            "count": 42,
            "message": "Hello"
        ]
        
        let config = AppDefaultConfig.build(configs: stringConfigs)
        
        #expect(config.configs.count == 3)
        #expect(config.configs[AnyCodingKey(stringValue: "flag")] as? Bool == true)
        #expect(config.configs[AnyCodingKey(stringValue: "count")] as? Int == 42)
        #expect(config.configs[AnyCodingKey(stringValue: "message")] as? String == "Hello")
    }

    @Test("builds with additional typed configs")
    func buildsWithAdditionalTypedConfigs() {
        let stringConfigs = ["string_key": "value"]
        let typedKey = AnyCodingKey(stringValue: "typed_key")
        let additionalConfigs = [typedKey: 3.14 as any Encodable]
        
        let config = AppDefaultConfig.build(
            configs: stringConfigs,
            additionalConfigs: additionalConfigs
        )
        
        #expect(config.configs.count == 2)
        #expect(config.configs[AnyCodingKey(stringValue: "string_key")] as? String == "value")
        #expect(config.configs[typedKey] as? Double == 3.14)
    }

    @Test("encodes to JSON successfully")
    func encodesToJSON() throws {
        let config = AppDefaultConfig.build(configs: [
            "flag": true,
            "count": 42,
            "message": "Hello"
        ])
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(config)
        
        // Verify we can decode it back to a dictionary
        let decoded = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        #expect(decoded?["flag"] as? Bool == true)
        #expect(decoded?["count"] as? Int == 42)
        #expect(decoded?["message"] as? String == "Hello")
    }

    @Test("handles various encodable types")
    func handlesVariousEncodableTypes() throws {
        let config = AppDefaultConfig.build(configs: [
            "string": "text",
            "int": 123,
            "double": 45.67,
            "bool": false,
            "array": [1, 2, 3]
        ])
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(config)
        let decoded = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        #expect(decoded?["string"] as? String == "text")
        #expect(decoded?["int"] as? Int == 123)
        #expect(decoded?["double"] as? Double == 45.67)
        #expect(decoded?["bool"] as? Bool == false)
        #expect(decoded?["array"] as? [Int] == [1, 2, 3])
    }
}