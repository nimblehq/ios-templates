import FactoryKit
import Testing

@testable import Domain

@Suite("CheckForceUpdateUseCase")
struct CheckForceUpdateUseCaseTests {

    @Test("returns false when the current version equals the minimum required version")
    func returnsFalseWhenCurrentVersionEqualsMinimumRequiredVersion() async {
        await withSUT(minimumVersion: "1.0.0", currentVersion: AppVersion(major: 1, minor: 0, patch: 0)) { useCase in
            #expect(await useCase.execute() == false)
        }
    }

    @Test("returns false when the current version is above the minimum required version")
    func returnsFalseWhenCurrentVersionIsAboveMinimumRequiredVersion() async {
        await withSUT(minimumVersion: "1.5.0", currentVersion: AppVersion(major: 2, minor: 0, patch: 0)) { useCase in
            #expect(await useCase.execute() == false)
        }
    }

    @Test("returns true when the current version is below the minimum required version")
    func returnsTrueWhenCurrentVersionIsBelowMinimumRequiredVersion() async {
        await withSUT(minimumVersion: "1.1.0", currentVersion: AppVersion(major: 1, minor: 0, patch: 0)) { useCase in
            #expect(await useCase.execute() == true)
        }
    }

}

// MARK: - Helpers

private func withSUT(
    minimumVersion: String,
    currentVersion: AppVersion,
    _ test: (CheckForceUpdateUseCase) async -> Void
) async {
    Container.shared.reset()
    Container.shared.remoteConfigRepository.register { StubRemoteConfigRepository(minimumVersion: minimumVersion) }
    defer { Container.shared.reset() }

    await test(CheckForceUpdateUseCase(currentVersion: currentVersion))
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

