import Testing

@testable import Domain

@Suite("CheckForceUpdateUseCase")
struct CheckForceUpdateUseCaseTests {

    @Test("returns false when the current version equals the minimum required version")
    func returnsFalseWhenCurrentVersionEqualsMinimumRequiredVersion() async {
        let repository = StubRemoteConfigRepository(minimumVersion: "1.0.0")
        let useCase = CheckForceUpdateUseCase(
            remoteConfigRepository: repository,
            currentVersion: AppVersion(major: 1, minor: 0, patch: 0)
        )

        #expect(await useCase() == false)
    }

    @Test("returns false when the current version is above the minimum required version")
    func returnsFalseWhenCurrentVersionIsAboveMinimumRequiredVersion() async {
        let repository = StubRemoteConfigRepository(minimumVersion: "1.5.0")
        let useCase = CheckForceUpdateUseCase(
            remoteConfigRepository: repository,
            currentVersion: AppVersion(major: 2, minor: 0, patch: 0)
        )

        #expect(await useCase() == false)
    }

    @Test("returns true when the current version is below the minimum required version")
    func returnsTrueWhenCurrentVersionIsBelowMinimumRequiredVersion() async {
        let repository = StubRemoteConfigRepository(minimumVersion: "1.1.0")
        let useCase = CheckForceUpdateUseCase(
            remoteConfigRepository: repository,
            currentVersion: AppVersion(major: 1, minor: 0, patch: 0)
        )

        #expect(await useCase() == true)
    }
}

private actor StubRemoteConfigRepository: RemoteConfigRepository {

    private let minimumVersion: String

    init(minimumVersion: String) {
        self.minimumVersion = minimumVersion
    }

    func refresh() async throws {}

    func value<Value: RemoteConfigValueConvertible>(for key: RemoteConfigKey<Value>) async -> Value {
        if key.name == RemoteConfigKey<AppVersion>.minimumAppVersion.name,
           let version = AppVersion(string: minimumVersion) as? Value {
            return version
        }
        return key.defaultValue
    }
}
