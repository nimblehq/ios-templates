import Foundation
import Testing

@testable import Domain

@Suite("RatingPromptData")
struct RatingPromptDataTests {

    @Test("initializes with default values")
    func initializesWithDefaultValues() {
        let data = RatingPromptData()
        
        #expect(data.appLaunchCount == 0)
        #expect(data.firstLaunchDate == nil)
        #expect(data.lastPromptedVersion == nil)
        #expect(data.significantEventCount == 0)
    }
    
    @Test("initializes with custom values")
    func initializesWithCustomValues() {
        let firstLaunchDate = Date()
        let data = RatingPromptData(
            appLaunchCount: 5,
            firstLaunchDate: firstLaunchDate,
            lastPromptedVersion: "1.2.0",
            significantEventCount: 3
        )
        
        #expect(data.appLaunchCount == 5)
        #expect(data.firstLaunchDate == firstLaunchDate)
        #expect(data.lastPromptedVersion == "1.2.0")
        #expect(data.significantEventCount == 3)
    }
    
    @Test("calculates days since first launch correctly")
    func calculatesDaysSinceFirstLaunchCorrectly() {
        let calendar = Calendar.current
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        
        let data = RatingPromptData(firstLaunchDate: sevenDaysAgo)
        
        #expect(data.daysSinceFirstLaunch == 7)
    }
    
    @Test("returns zero days when first launch date is nil")
    func returnsZeroDaysWhenFirstLaunchDateIsNil() {
        let data = RatingPromptData()
        
        #expect(data.daysSinceFirstLaunch == 0)
    }
    
    @Test("returns false for hasBeenPromptedForCurrentVersion when lastPromptedVersion is nil")
    func returnsFalseForHasBeenPromptedForCurrentVersionWhenLastPromptedVersionIsNil() {
        let data = RatingPromptData()
        
        #expect(data.hasBeenPromptedForCurrentVersion("1.0.0") == false)
    }
    
    @Test("returns true when current version matches lastPromptedVersion")
    func returnsTrueWhenCurrentVersionMatchesLastPromptedVersion() {
        let data = RatingPromptData(lastPromptedVersion: "1.2.0")
        
        #expect(data.hasBeenPromptedForCurrentVersion("1.2.0") == true)
    }
    
    @Test("returns false when current version differs from lastPromptedVersion")
    func returnsFalseWhenCurrentVersionDiffersFromLastPromptedVersion() {
        let data = RatingPromptData(lastPromptedVersion: "1.2.0")
        
        #expect(data.hasBeenPromptedForCurrentVersion("1.3.0") == false)
    }
    
    @Test("is codable")
    func isCodable() throws {
        let originalData = RatingPromptData(
            appLaunchCount: 10,
            firstLaunchDate: Date(),
            lastPromptedVersion: "2.1.0",
            significantEventCount: 5
        )
        
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let encodedData = try encoder.encode(originalData)
        let decodedData = try decoder.decode(RatingPromptData.self, from: encodedData)
        
        #expect(decodedData.appLaunchCount == originalData.appLaunchCount)
        #expect(decodedData.firstLaunchDate?.timeIntervalSince1970 == originalData.firstLaunchDate?.timeIntervalSince1970)
        #expect(decodedData.lastPromptedVersion == originalData.lastPromptedVersion)
        #expect(decodedData.significantEventCount == originalData.significantEventCount)
    }
}
