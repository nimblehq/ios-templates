import Testing

@testable import Data
import Domain
import FactoryKit

@Suite("DefaultFeatureFlagRepository", .serialized)
struct DefaultFeatureFlagRepositoryTests {

    @Test("reads feature flags through the remote config repository")
    func readsFeatureFlagsThroughTheRemoteConfigRepository() async {
        Container.shared.reset()
        defer { Container.shared.reset() }

        let welcomeFlag = FeatureFlag(name: "welcome_enabled")
        Container.shared.remoteConfigRepository.register {
            StubRemoteConfigRepository(values: [
                welcomeFlag.name: .bool(true)
            ])
        }
        let repository = DefaultFeatureFlagRepository()

        let isEnabled = await repository.isEnabled(welcomeFlag)

        #expect(isEnabled == true)
    }

    @Test("falls back to the flag default value")
    func fallsBackToTheFlagDefaultValue() async {
        Container.shared.reset()
        defer { Container.shared.reset() }

        Container.shared.remoteConfigRepository.register { StubRemoteConfigRepository() }
        let repository = DefaultFeatureFlagRepository()
        let featureFlag = FeatureFlag(name: "new_home_enabled", defaultValue: true)

        let isEnabled = await repository.isEnabled(featureFlag)

        #expect(isEnabled == true)
    }
}

private struct StubRemoteConfigRepository: RemoteConfigRepository {

    var values: [String: RemoteConfigStoredValue] = [:]

    func refresh() async throws {}

    func value<Value: RemoteConfigValueConvertible>(for key: RemoteConfigKey<Value>) async -> Value {
        guard let storedValue = values[key.name],
              let value = Value.makeRemoteConfigValue(from: storedValue) else {
            return key.defaultValue
        }

        return value
    }
}
