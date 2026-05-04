import Foundation

@testable import Data

final class UserDefaultsManagerMock: UserDefaultsManagerProtocol, @unchecked Sendable {
    
    private var storage: [String: Any] = [:]
    private var synchronizeCallCount = 0
    
    var didCallSynchronize: Bool { synchronizeCallCount > 0 }
    var synchronizeCallCountValue: Int { synchronizeCallCount }
    
    func set(_ value: Any?, for key: String) {
        if let value = value {
            storage[key] = value
        } else {
            storage.removeValue(forKey: key)
        }
    }
    
    func setObject<T: Codable>(_ value: T?, key: String) {
        if let value = value {
            storage[key] = value
        } else {
            storage.removeValue(forKey: key)
        }
    }
    
    func getStringValue(for key: String) -> String? {
        return storage[key] as? String
    }
    
    func getBooleanValue(for key: String) -> Bool {
        return storage[key] as? Bool ?? false
    }
    
    func getIntValue(for key: String) -> Int {
        return storage[key] as? Int ?? 0
    }
    
    func getArray(for key: String) -> [Any]? {
        return storage[key] as? [Any]
    }
    
    func getDataValue(for key: String) -> Data? {
        return storage[key] as? Data
    }
    
    func getObject<T: Codable>(ofType: T.Type, key: String) -> T? {
        return storage[key] as? T
    }
    
    func getValue(for key: String) -> Any? {
        return storage[key]
    }
    
    func getAllKeys(withPrefix prefix: String) -> [String] {
        return storage.keys.filter { $0.hasPrefix(prefix) }
    }
    
    func clearData(forKeys keys: [String]) {
        keys.forEach { storage.removeValue(forKey: $0) }
    }
    
    func clearDataForCommonKeys() {
        storage.removeAll()
    }
    
    func synchronize() {
        synchronizeCallCount += 1
    }
    
    // Test helper methods
    func reset() {
        storage.removeAll()
        synchronizeCallCount = 0
    }
    
    func setStorageValue(_ value: Any?, forKey key: String) {
        storage[key] = value
    }
}
