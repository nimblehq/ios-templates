import Foundation
import Testing

@testable import Data
import Domain

@Suite("RatingPromptRepository")
struct RatingPromptRepositoryTests {

    @Test("getRatingPromptData returns data with default values when no data is stored")
    func getRatingPromptDataReturnsDataWithDefaultValuesWhenNoDataIsStored() async {
        let userDefaultsManager = UserDefaultsManagerMock()
        let repository = RatingPromptRepository(userDefaultsManager: userDefaultsManager)

        let data = await repository.getRatingPromptData()

        #expect(data.appLaunchCount == 0)
        #expect(data.firstLaunchDate == nil)
        #expect(data.lastPromptedVersion == nil)
        #expect(data.significantEventCount == 0)
    }

    @Test("getRatingPromptData returns stored values")
    func getRatingPromptDataReturnsStoredValues() async throws {
        let userDefaultsManager = UserDefaultsManagerMock()
        let testDate = Date()
        let encodedDate = try JSONEncoder().encode(testDate)

        userDefaultsManager.setStorageValue(5, forKey: UserDefaultsKey.ratingPromptAppLaunchCount.rawValue)
        userDefaultsManager.setStorageValue(encodedDate, forKey: UserDefaultsKey.ratingPromptFirstLaunchDate.rawValue)
        userDefaultsManager.setStorageValue("1.2.0", forKey: UserDefaultsKey.ratingPromptLastPromptedVersion.rawValue)
        userDefaultsManager.setStorageValue(3, forKey: UserDefaultsKey.ratingPromptSignificantEventCount.rawValue)

        let repository = RatingPromptRepository(userDefaultsManager: userDefaultsManager)
        let data = await repository.getRatingPromptData()

        #expect(data.appLaunchCount == 5)
        #expect(data.firstLaunchDate?.timeIntervalSince1970 == testDate.timeIntervalSince1970)
        #expect(data.lastPromptedVersion == "1.2.0")
        #expect(data.significantEventCount == 3)
    }

    @Test("getRatingPromptData handles invalid date data gracefully")
    func getRatingPromptDataHandlesInvalidDateDataGracefully() async {
        let userDefaultsManager = UserDefaultsManagerMock()
        let invalidDateData = Data([0x00, 0x01, 0x02]) // Invalid JSON for Date

        userDefaultsManager.setStorageValue(invalidDateData, forKey: UserDefaultsKey.ratingPromptFirstLaunchDate.rawValue)

        let repository = RatingPromptRepository(userDefaultsManager: userDefaultsManager)
        let data = await repository.getRatingPromptData()

        #expect(data.firstLaunchDate == nil)
    }

    @Test("recordAppLaunch increments launch count")
    func recordAppLaunchIncrementsLaunchCount() async {
        let userDefaultsManager = UserDefaultsManagerMock()
        userDefaultsManager.setStorageValue(5, forKey: UserDefaultsKey.ratingPromptAppLaunchCount.rawValue)

        let repository = RatingPromptRepository(userDefaultsManager: userDefaultsManager)
        await repository.recordAppLaunch()

        let updatedCount = userDefaultsManager.getIntValue(for: UserDefaultsKey.ratingPromptAppLaunchCount.rawValue)
        #expect(updatedCount == 6)
        #expect(userDefaultsManager.didCallSynchronize)
    }

    @Test("recordAppLaunch sets first launch date when not already set")
    func recordAppLaunchSetsFirstLaunchDateWhenNotAlreadySet() async throws {
        let userDefaultsManager = UserDefaultsManagerMock()
        let repository = RatingPromptRepository(userDefaultsManager: userDefaultsManager)

        await repository.recordAppLaunch()

        let dateData = userDefaultsManager.getDataValue(for: UserDefaultsKey.ratingPromptFirstLaunchDate.rawValue)
        #expect(dateData != nil)

        let decodedDate = try JSONDecoder().decode(Date.self, from: dateData!)
        let now = Date()
        // Allow for small time difference (within 1 second)
        #expect(abs(decodedDate.timeIntervalSince(now)) < 1.0)
    }

    @Test("recordAppLaunch does not overwrite existing first launch date")
    func recordAppLaunchDoesNotOverwriteExistingFirstLaunchDate() async throws {
        let userDefaultsManager = UserDefaultsManagerMock()
        let existingDate = Date().addingTimeInterval(-1000)
        let encodedExistingDate = try JSONEncoder().encode(existingDate)

        userDefaultsManager.setStorageValue(encodedExistingDate, forKey: UserDefaultsKey.ratingPromptFirstLaunchDate.rawValue)

        let repository = RatingPromptRepository(userDefaultsManager: userDefaultsManager)
        await repository.recordAppLaunch()

        let dateData = userDefaultsManager.getDataValue(for: UserDefaultsKey.ratingPromptFirstLaunchDate.rawValue)!
        let storedDate = try JSONDecoder().decode(Date.self, from: dateData)

        #expect(storedDate.timeIntervalSince1970 == existingDate.timeIntervalSince1970)
    }

    @Test("recordSignificantEvent increments significant event count")
    func recordSignificantEventIncrementsSignificantEventCount() async {
        let userDefaultsManager = UserDefaultsManagerMock()
        userDefaultsManager.setStorageValue(3, forKey: UserDefaultsKey.ratingPromptSignificantEventCount.rawValue)

        let repository = RatingPromptRepository(userDefaultsManager: userDefaultsManager)
        await repository.recordSignificantEvent()

        let updatedCount = userDefaultsManager.getIntValue(for: UserDefaultsKey.ratingPromptSignificantEventCount.rawValue)
        #expect(updatedCount == 4)
        #expect(userDefaultsManager.didCallSynchronize)
    }

    @Test("recordPromptShown stores the app version")
    func recordPromptShownStoresTheAppVersion() async {
        let userDefaultsManager = UserDefaultsManagerMock()
        let repository = RatingPromptRepository(userDefaultsManager: userDefaultsManager)

        await repository.recordPromptShown(for: "2.1.0")

        let storedVersion = userDefaultsManager.getStringValue(for: UserDefaultsKey.ratingPromptLastPromptedVersion.rawValue)
        #expect(storedVersion == "2.1.0")
        #expect(userDefaultsManager.didCallSynchronize)
    }

    @Test("resetCounters resets launch and event counters to zero")
    func resetCountersResetsLaunchAndEventCountersToZero() async {
        let userDefaultsManager = UserDefaultsManagerMock()
        userDefaultsManager.setStorageValue(10, forKey: UserDefaultsKey.ratingPromptAppLaunchCount.rawValue)
        userDefaultsManager.setStorageValue(5, forKey: UserDefaultsKey.ratingPromptSignificantEventCount.rawValue)

        let repository = RatingPromptRepository(userDefaultsManager: userDefaultsManager)
        await repository.resetCounters()

        let launchCount = userDefaultsManager.getIntValue(for: UserDefaultsKey.ratingPromptAppLaunchCount.rawValue)
        let eventCount = userDefaultsManager.getIntValue(for: UserDefaultsKey.ratingPromptSignificantEventCount.rawValue)

        #expect(launchCount == 0)
        #expect(eventCount == 0)
        #expect(userDefaultsManager.didCallSynchronize)
    }

    @Test("clearAllData removes all rating prompt related data")
    func clearAllDataRemovesAllRatingPromptRelatedData() async throws {
        let userDefaultsManager = UserDefaultsManagerMock()
        let testDate = Date()
        let encodedDate = try JSONEncoder().encode(testDate)

        // Set up initial data
        userDefaultsManager.setStorageValue(10, forKey: UserDefaultsKey.ratingPromptAppLaunchCount.rawValue)
        userDefaultsManager.setStorageValue(encodedDate, forKey: UserDefaultsKey.ratingPromptFirstLaunchDate.rawValue)
        userDefaultsManager.setStorageValue("1.0.0", forKey: UserDefaultsKey.ratingPromptLastPromptedVersion.rawValue)
        userDefaultsManager.setStorageValue(5, forKey: UserDefaultsKey.ratingPromptSignificantEventCount.rawValue)

        let repository = RatingPromptRepository(userDefaultsManager: userDefaultsManager)
        await repository.clearAllData()

        // Verify all data is cleared
        let data = await repository.getRatingPromptData()
        #expect(data.appLaunchCount == 0)
        #expect(data.firstLaunchDate == nil)
        #expect(data.lastPromptedVersion == nil)
        #expect(data.significantEventCount == 0)
        #expect(userDefaultsManager.didCallSynchronize)
    }
}
