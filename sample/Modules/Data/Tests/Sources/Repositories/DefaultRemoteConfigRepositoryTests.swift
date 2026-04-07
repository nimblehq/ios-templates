import Testing

@testable import Data
import Domain

@Suite("DefaultRemoteConfigRepository")
struct DefaultRemoteConfigRepositoryTests {

    @Test("returns a typed stored value")
    func returnsATypedStoredValue() async {
        let booleanKey = RemoteConfigKey(name: "feature_enabled", defaultValue: false)
        let repository = DefaultRemoteConfigRepository(
            source: StubRemoteConfigSource(values: [
                booleanKey.name: .string("true")
            ])
        )

        let value = await repository.value(for: booleanKey)

        #expect(value == true)
    }

    @Test("falls back to the key default value when the source has no value")
    func fallsBackToTheKeyDefaultValueWhenTheSourceHasNoValue() async {
        let titleKey = RemoteConfigKey(name: "feature_title", defaultValue: "Default title")
        let repository = DefaultRemoteConfigRepository(
            source: StubRemoteConfigSource()
        )

        let value = await repository.value(for: titleKey)

        #expect(value == "Default title")
    }
}

private actor StubRemoteConfigSource: RemoteConfigSource {

    private let values: [String: RemoteConfigStoredValue]

    init(values: [String: RemoteConfigStoredValue] = [:]) {
        self.values = values
    }

    func refresh() async throws {}

    func value(forKey key: String) async -> RemoteConfigStoredValue? {
        values[key]
    }
}
