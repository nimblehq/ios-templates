# Test Doubles

## When to use this reference

Use when creating stubs, fakes, or mocks for testing. This project uses inline protocol-conforming stubs — not generated mocks.

## Project convention: inline private stubs

Define stubs as `private struct` or `private actor` at the bottom of the test file, conforming to the domain protocol.

### `private struct` — for sync protocols or immutable state

```swift
@Suite("DefaultFeatureFlagRepository")
struct DefaultFeatureFlagRepositoryTests {

    @Test("reads feature flags through the remote config repository")
    func readsFeatureFlagsThroughTheRemoteConfigRepository() async {
        let repository = DefaultFeatureFlagRepository(
            remoteConfigRepository: StubRemoteConfigRepository(values: [
                "welcome_enabled": .bool(true)
            ])
        )

        let isEnabled = await repository.isEnabled(FeatureFlag(name: "welcome_enabled"))

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
```

### `private actor` — for async protocols or mutable shared state

```swift
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
```

### When to use which

| Scenario | Use |
|----------|-----|
| Protocol has only sync methods | `private struct` |
| Protocol has `async` methods but stub state is immutable | `private struct` (with `async` methods) or `private actor` |
| Protocol has `async` methods and stub needs mutable state | `private actor` |
| Stub needs to record calls for verification | `private actor` (or `private class` with `@unchecked Sendable`) |

## Network-level stubs (OHHTTPStubs)

For tests that exercise the actual network layer (e.g. `NetworkAPI`), use the existing `NetworkStubber`:

```swift
@Test("returns the response when network succeeds")
func returnsTheResponseWhenNetworkSucceeds() async throws {
    let config = DummyRequestConfiguration()
    NetworkStubber.addStub(config)
    let networkAPI = NetworkAPI()

    let response = try await networkAPI.performRequest(config, for: DummyNetworkModel.self)

    #expect(response.message == "Hello")
    NetworkStubber.removeAllStubs()
}
```

- `NetworkStubber` lives in `Modules/Data/Tests/Sources/Utilities/NetworkStubber.swift`.
- `DummyRequestConfiguration` lives in `Modules/Data/Tests/Sources/Dummies/DummyRequestConfiguration.swift`.
- Always call `NetworkStubber.removeAllStubs()` after each test.

## Shared test doubles in `Dummies/`

For test doubles reused across multiple test files in a module, place them in `Tests/Sources/Dummies/`:

```
Modules/Data/Tests/Sources/
├── Dummies/
│   ├── DummyRequestConfiguration.swift
│   └── DummyNetworkModel.swift
├── Repositories/
│   └── DefaultRemoteConfigRepositoryTests.swift
└── Utilities/
    └── NetworkStubber.swift
```

Only move a stub to `Dummies/` when it's genuinely reused. Default to inline `private` stubs.

## In-memory fakes for fast tests

Prefer in-memory implementations for the fast unit test path:

```swift
private struct InMemoryTokenStore: TokenStore {

    private var tokens: [String: String] = [:]

    mutating func store(key: String, value: String) {
        tokens[key] = value
    }

    func retrieve(key: String) -> String? {
        tokens[key]
    }
}
```

Reserve real integration dependencies (database, keychain, network) for dedicated integration test suites.

## Do / Don't

- **Do** define stubs inline as `private` types at the bottom of the test file.
- **Do** conform stubs to the domain protocol directly.
- **Do** use `actor` for stubs with async protocols or mutable state.
- **Don't** use mock generation libraries.
- **Don't** create shared stubs unless they're genuinely reused across files.
- **Don't** put stub logic in production code.
