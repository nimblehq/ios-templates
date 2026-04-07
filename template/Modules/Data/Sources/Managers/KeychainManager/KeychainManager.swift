import Foundation
import KeychainAccess

final class KeychainManager: KeychainManagerProtocol, @unchecked Sendable {

    private let keychain: Keychain

    init(service: String = Bundle.main.bundleIdentifier ?? "") {
        keychain = Keychain(service: service)
    }

    // MARK: - KeychainKey

    func get(_ key: KeychainKey) throws -> String? {
        try keychain.getString(key.rawValue)
    }

    func set(_ value: String, for key: KeychainKey) throws {
        try keychain.set(value, key: key.rawValue)
    }

    func get<T: Decodable>(_ key: KeychainKey) throws -> T? {
        try keychain
            .getData(key.rawValue)
            .map { try JSONDecoder().decode(T.self, from: $0) }
    }

    func set<T: Encodable>(_ value: T?, for key: KeychainKey) throws {
        guard let value else { return try remove(key) }
        try keychain.set(JSONEncoder().encode(value), key: key.rawValue)
    }

    func remove(_ key: KeychainKey) throws {
        try keychain.remove(key.rawValue)
    }

    func removeAll() throws {
        for key in KeychainKey.allCases {
            try keychain.remove(key.rawValue)
        }
    }

    // MARK: - String key

    func get(_ key: String) throws -> String? {
        try keychain.getString(key)
    }

    func set(_ value: String, for key: String) throws {
        try keychain.set(value, key: key)
    }

    func get<T: Decodable>(_ key: String) throws -> T? {
        try keychain
            .getData(key)
            .map { try JSONDecoder().decode(T.self, from: $0) }
    }

    func set<T: Encodable>(_ value: T?, for key: String) throws {
        guard let value else { return try remove(key) }
        try keychain.set(JSONEncoder().encode(value), key: key)
    }

    func remove(_ key: String) throws {
        try keychain.remove(key)
    }
}
