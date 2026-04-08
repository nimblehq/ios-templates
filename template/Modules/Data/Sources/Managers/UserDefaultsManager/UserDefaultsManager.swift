import Foundation

final class UserDefaultsManager: UserDefaultsManagerProtocol, @unchecked Sendable {

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func set(_ value: Any?, for key: String) {
        if let value {
            userDefaults.set(value, forKey: key)
        } else {
            userDefaults.removeObject(forKey: key)
        }
    }

    func setObject<T: Codable>(_ value: T?, key: String) {
        guard let value else {
            return userDefaults.removeObject(forKey: key)
        }
        guard let data = try? JSONEncoder().encode(value) else { return }
        userDefaults.setValue(data, forKey: key)
    }

    func getStringValue(for key: String) -> String? {
        userDefaults.string(forKey: key)
    }

    func getBooleanValue(for key: String) -> Bool {
        userDefaults.bool(forKey: key)
    }

    func getIntValue(for key: String) -> Int {
        userDefaults.integer(forKey: key)
    }

    func getArray(for key: String) -> [Any]? {
        userDefaults.array(forKey: key)
    }

    func getDataValue(for key: String) -> Data? {
        userDefaults.data(forKey: key)
    }

    func getObject<T: Codable>(ofType: T.Type, key: String) -> T? {
        guard let data = userDefaults.value(forKey: key) as? Data else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    func getValue(for key: String) -> Any? {
        userDefaults.object(forKey: key)
    }

    func getAllKeys(withPrefix prefix: String) -> [String] {
        Array(userDefaults.dictionaryRepresentation().keys).filter { $0.hasPrefix(prefix) }
    }

    func clearData(forKeys keys: [String]) {
        keys.forEach { userDefaults.removeObject(forKey: $0) }
    }

    func clearDataForCommonKeys() {
        let keys = UserDefaultsKey.allCases.map(\.rawValue)
        clearData(forKeys: keys)
    }

    func synchronize() {
        userDefaults.synchronize()
    }
}
