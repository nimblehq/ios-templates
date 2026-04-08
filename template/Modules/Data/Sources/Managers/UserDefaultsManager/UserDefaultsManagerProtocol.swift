import Foundation

public protocol UserDefaultsManagerProtocol: AnyObject, Sendable {

    func set(_ value: Any?, for key: String)
    func setObject<T: Codable>(_ value: T?, key: String)

    func getStringValue(for key: String) -> String?
    func getBooleanValue(for key: String) -> Bool
    func getIntValue(for key: String) -> Int
    func getArray(for key: String) -> [Any]?
    func getDataValue(for key: String) -> Data?
    func getObject<T: Codable>(ofType: T.Type, key: String) -> T?
    func getValue(for key: String) -> Any?
    func getAllKeys(withPrefix prefix: String) -> [String]

    func clearData(forKeys keys: [String])
    func clearDataForCommonKeys()

    func synchronize()
}
