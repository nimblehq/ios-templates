import Foundation

public protocol KeychainManagerProtocol: AnyObject, Sendable {

    // KeychainKey
    func get(_ key: KeychainKey) throws -> String?
    func set(_ value: String, for key: KeychainKey) throws
    func get<T: Decodable>(_ key: KeychainKey) throws -> T?
    func set<T: Encodable>(_ value: T?, for key: KeychainKey) throws
    func remove(_ key: KeychainKey) throws
    func removeAll() throws

    // String key
    func get(_ key: String) throws -> String?
    func set(_ value: String, for key: String) throws
    func get<T: Decodable>(_ key: String) throws -> T?
    func set<T: Encodable>(_ value: T?, for key: String) throws
    func remove(_ key: String) throws
}
