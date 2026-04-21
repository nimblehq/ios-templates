import Domain
import Foundation

final class RatingPromptStorage: RatingPromptStorageProtocol, @unchecked Sendable {
    
    private let userDefaultsManager: UserDefaultsManagerProtocol
    private let lock = NSLock()
    
    init(userDefaultsManager: UserDefaultsManagerProtocol) {
        self.userDefaultsManager = userDefaultsManager
    }
    
    func getRatingPromptData() -> RatingPromptData {
        let appLaunchCount = userDefaultsManager.getIntValue(for: UserDefaultsKey.ratingPromptAppLaunchCount.rawValue)
        let firstLaunchDateData = userDefaultsManager.getDataValue(for: UserDefaultsKey.ratingPromptFirstLaunchDate.rawValue)
        let lastPromptedVersion = userDefaultsManager.getStringValue(for: UserDefaultsKey.ratingPromptLastPromptedVersion.rawValue)
        let significantEventCount = userDefaultsManager.getIntValue(for: UserDefaultsKey.ratingPromptSignificantEventCount.rawValue)
        
        var firstLaunchDate: Date?
        if let dateData = firstLaunchDateData {
            firstLaunchDate = try? JSONDecoder().decode(Date.self, from: dateData)
        }
        
        return RatingPromptData(
            appLaunchCount: appLaunchCount,
            firstLaunchDate: firstLaunchDate,
            lastPromptedVersion: lastPromptedVersion,
            significantEventCount: significantEventCount
        )
    }
    
    func recordAppLaunch() {
        lock.lock()
        defer { lock.unlock() }
        
        let currentCount = userDefaultsManager.getIntValue(for: UserDefaultsKey.ratingPromptAppLaunchCount.rawValue)
        userDefaultsManager.set(currentCount + 1, for: UserDefaultsKey.ratingPromptAppLaunchCount.rawValue)
        
        if userDefaultsManager.getDataValue(for: UserDefaultsKey.ratingPromptFirstLaunchDate.rawValue) == nil {
            let now = Date()
            if let dateData = try? JSONEncoder().encode(now) {
                userDefaultsManager.set(dateData, for: UserDefaultsKey.ratingPromptFirstLaunchDate.rawValue)
            }
        }
        
        userDefaultsManager.synchronize()
    }
    
    func recordSignificantEvent() {
        lock.lock()
        defer { lock.unlock() }
        
        let currentCount = userDefaultsManager.getIntValue(for: UserDefaultsKey.ratingPromptSignificantEventCount.rawValue)
        userDefaultsManager.set(currentCount + 1, for: UserDefaultsKey.ratingPromptSignificantEventCount.rawValue)
        userDefaultsManager.synchronize()
    }
    
    func recordPromptShown(for appVersion: String) {
        userDefaultsManager.set(appVersion, for: UserDefaultsKey.ratingPromptLastPromptedVersion.rawValue)
        userDefaultsManager.synchronize()
    }
    
    func resetCounters() {
        userDefaultsManager.set(0, for: UserDefaultsKey.ratingPromptAppLaunchCount.rawValue)
        userDefaultsManager.set(0, for: UserDefaultsKey.ratingPromptSignificantEventCount.rawValue)
        userDefaultsManager.synchronize()
    }
    
    func clearAllData() {
        let keys = [
            UserDefaultsKey.ratingPromptAppLaunchCount.rawValue,
            UserDefaultsKey.ratingPromptFirstLaunchDate.rawValue,
            UserDefaultsKey.ratingPromptLastPromptedVersion.rawValue,
            UserDefaultsKey.ratingPromptSignificantEventCount.rawValue
        ]
        userDefaultsManager.clearData(forKeys: keys)
        userDefaultsManager.synchronize()
    }
}
