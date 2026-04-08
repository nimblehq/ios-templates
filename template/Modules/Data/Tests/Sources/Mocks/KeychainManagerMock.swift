//
//  KeychainManagerMock.swift
//

@testable import Data

final class KeychainManagerMock: KeychainManagerProtocol, @unchecked Sendable {

    var data = [String: Any?]()

    // MARK: - KeychainKey

    func get(_ key: KeychainKey) throws -> String? {
        data[key.rawValue] as? String
    }

    func set(_ value: String, for key: KeychainKey) throws {
        data[key.rawValue] = value
    }

    func get<T: Decodable>(_ key: KeychainKey) throws -> T? {
        data[key.rawValue] as? T
    }

    func set<T: Encodable>(_ value: T?, for key: KeychainKey) throws {
        data[key.rawValue] = value
    }

    func remove(_ key: KeychainKey) throws {
        data.removeValue(forKey: key.rawValue)
    }

    func removeAll() throws {
        data = [:]
    }

    // MARK: - String key

    func get(_ key: String) throws -> String? {
        data[key] as? String
    }

    func set(_ value: String, for key: String) throws {
        data[key] = value
    }

    func get<T: Decodable>(_ key: String) throws -> T? {
        data[key] as? T
    }

    func set<T: Encodable>(_ value: T?, for key: String) throws {
        data[key] = value
    }

    func remove(_ key: String) throws {
        data.removeValue(forKey: key)
    }
}
