import Foundation
import Testing

@testable import Domain

@Suite("ShouldShowRatingPromptUseCase")
struct ShouldShowRatingPromptUseCaseTests {

    @Test("returns false when user has already been prompted for current version")
    func returnsFalseWhenUserHasAlreadyBeenPromptedForCurrentVersion() async {
        let repository = StubRatingPromptRepository(
            data: RatingPromptData(
                appLaunchCount: 20,
                firstLaunchDate: Date().addingTimeInterval(-10 * 24 * 60 * 60), // 10 days ago
                lastPromptedVersion: "1.0.0",
                significantEventCount: 10
            )
        )
        let useCase = ShouldShowRatingPromptUseCase(
            repository: repository,
            currentVersion: "1.0.0"
        )
        let configuration = RatingPromptConfiguration(
            minimumDaysSinceFirstLaunch: 7,
            minimumAppLaunches: 10,
            minimumSignificantEvents: 5
        )

        let result = await useCase(configuration: configuration)

        #expect(result == false)
    }

    @Test("returns true when user has been prompted for different version")
    func returnsTrueWhenUserHasBeenPromptedForDifferentVersion() async {
        let repository = StubRatingPromptRepository(
            data: RatingPromptData(
                appLaunchCount: 20,
                firstLaunchDate: Date().addingTimeInterval(-10 * 24 * 60 * 60), // 10 days ago
                lastPromptedVersion: "1.0.0",
                significantEventCount: 10
            )
        )
        let useCase = ShouldShowRatingPromptUseCase(
            repository: repository,
            currentVersion: "1.1.0"
        )
        let configuration = RatingPromptConfiguration(
            minimumDaysSinceFirstLaunch: 7,
            minimumAppLaunches: 10,
            minimumSignificantEvents: 5
        )

        let result = await useCase(configuration: configuration)

        #expect(result == true)
    }

    @Test("returns false when not enough days have passed since first launch")
    func returnsFalseWhenNotEnoughDaysHavePassedSinceFirstLaunch() async {
        let repository = StubRatingPromptRepository(
            data: RatingPromptData(
                appLaunchCount: 20,
                firstLaunchDate: Date().addingTimeInterval(-5 * 24 * 60 * 60), // 5 days ago
                lastPromptedVersion: nil,
                significantEventCount: 10
            )
        )
        let useCase = ShouldShowRatingPromptUseCase(
            repository: repository,
            currentVersion: "1.0.0"
        )
        let configuration = RatingPromptConfiguration(
            minimumDaysSinceFirstLaunch: 7,
            minimumAppLaunches: 10,
            minimumSignificantEvents: 5
        )

        let result = await useCase(configuration: configuration)

        #expect(result == false)
    }

    @Test("returns true when app launches insufficient but significant events sufficient")
    func returnsTrueWhenAppLaunchesInsufficientButSignificantEventsSufficient() async {
        let repository = StubRatingPromptRepository(
            data: RatingPromptData(
                appLaunchCount: 5,
                firstLaunchDate: Date().addingTimeInterval(-10 * 24 * 60 * 60), // 10 days ago
                lastPromptedVersion: nil,
                significantEventCount: 10
            )
        )
        let useCase = ShouldShowRatingPromptUseCase(
            repository: repository,
            currentVersion: "1.0.0"
        )
        let configuration = RatingPromptConfiguration(
            minimumDaysSinceFirstLaunch: 7,
            minimumAppLaunches: 10,
            minimumSignificantEvents: 5
        )

        let result = await useCase(configuration: configuration)

        #expect(result == true)
    }

    @Test("returns true when significant events insufficient but app launches sufficient")
    func returnsTrueWhenSignificantEventsInsufficientButAppLaunchesSufficient() async {
        let repository = StubRatingPromptRepository(
            data: RatingPromptData(
                appLaunchCount: 20,
                firstLaunchDate: Date().addingTimeInterval(-10 * 24 * 60 * 60), // 10 days ago
                lastPromptedVersion: nil,
                significantEventCount: 2
            )
        )
        let useCase = ShouldShowRatingPromptUseCase(
            repository: repository,
            currentVersion: "1.0.0"
        )
        let configuration = RatingPromptConfiguration(
            minimumDaysSinceFirstLaunch: 7,
            minimumAppLaunches: 10,
            minimumSignificantEvents: 5
        )

        let result = await useCase(configuration: configuration)

        #expect(result == true)
    }

    @Test("returns true when all criteria are met")
    func returnsTrueWhenAllCriteriaAreMet() async {
        let repository = StubRatingPromptRepository(
            data: RatingPromptData(
                appLaunchCount: 20,
                firstLaunchDate: Date().addingTimeInterval(-10 * 24 * 60 * 60), // 10 days ago
                lastPromptedVersion: nil,
                significantEventCount: 10
            )
        )
        let useCase = ShouldShowRatingPromptUseCase(
            repository: repository,
            currentVersion: "1.0.0"
        )
        let configuration = RatingPromptConfiguration(
            minimumDaysSinceFirstLaunch: 7,
            minimumAppLaunches: 10,
            minimumSignificantEvents: 5
        )

        let result = await useCase(configuration: configuration)

        #expect(result == true)
    }

    @Test("returns true when exactly meeting minimum requirements")
    func returnsTrueWhenExactlyMeetingMinimumRequirements() async {
        let repository = StubRatingPromptRepository(
            data: RatingPromptData(
                appLaunchCount: 10,
                firstLaunchDate: Date().addingTimeInterval(-7 * 24 * 60 * 60), // 7 days ago
                lastPromptedVersion: nil,
                significantEventCount: 5
            )
        )
        let useCase = ShouldShowRatingPromptUseCase(
            repository: repository,
            currentVersion: "1.0.0"
        )
        let configuration = RatingPromptConfiguration(
            minimumDaysSinceFirstLaunch: 7,
            minimumAppLaunches: 10,
            minimumSignificantEvents: 5
        )

        let result = await useCase(configuration: configuration)

        #expect(result == true)
    }

    @Test("uses default current version when not provided")
    func usesDefaultCurrentVersionWhenNotProvided() async {
        let repository = StubRatingPromptRepository(
            data: RatingPromptData(
                appLaunchCount: 20,
                firstLaunchDate: Date().addingTimeInterval(-10 * 24 * 60 * 60), // 10 days ago
                lastPromptedVersion: nil,
                significantEventCount: 10
            )
        )
        let useCase = ShouldShowRatingPromptUseCase(repository: repository)
        let configuration = RatingPromptConfiguration(
            minimumDaysSinceFirstLaunch: 7,
            minimumAppLaunches: 10,
            minimumSignificantEvents: 5
        )

        let result = await useCase(configuration: configuration)

        #expect(result == true)
    }

    @Test("returns false when both app launches and significant events are insufficient")
    func returnsFalseWhenBothAppLaunchesAndSignificantEventsAreInsufficient() async {
        let repository = StubRatingPromptRepository(
            data: RatingPromptData(
                appLaunchCount: 5,
                firstLaunchDate: Date().addingTimeInterval(-10 * 24 * 60 * 60), // 10 days ago
                lastPromptedVersion: nil,
                significantEventCount: 2
            )
        )
        let useCase = ShouldShowRatingPromptUseCase(
            repository: repository,
            currentVersion: "1.0.0"
        )
        let configuration = RatingPromptConfiguration(
            minimumDaysSinceFirstLaunch: 7,
            minimumAppLaunches: 10,
            minimumSignificantEvents: 5
        )

        let result = await useCase(configuration: configuration)

        #expect(result == false)
    }

    @Test("handles missing first launch date gracefully")
    func handlesMissingFirstLaunchDateGracefully() async {
        let repository = StubRatingPromptRepository(
            data: RatingPromptData(
                appLaunchCount: 20,
                firstLaunchDate: nil,
                lastPromptedVersion: nil,
                significantEventCount: 10
            )
        )
        let useCase = ShouldShowRatingPromptUseCase(
            repository: repository,
            currentVersion: "1.0.0"
        )
        let configuration = RatingPromptConfiguration(
            minimumDaysSinceFirstLaunch: 7,
            minimumAppLaunches: 10,
            minimumSignificantEvents: 5
        )

        let result = await useCase(configuration: configuration)

        // Should return false because daysSinceFirstLaunch returns 0 when firstLaunchDate is nil
        #expect(result == false)
    }
}

private final class StubRatingPromptRepository: RatingPromptRepositoryProtocol, @unchecked Sendable {

    private let data: RatingPromptData

    init(data: RatingPromptData) {
        self.data = data
    }

    func getRatingPromptData() async -> RatingPromptData {
        data
    }

    func recordAppLaunch() async {}

    func recordSignificantEvent() async {}

    func recordPromptShown(for appVersion: String) async {}

    func resetCounters() async {}

    func clearAllData() async {}
}
