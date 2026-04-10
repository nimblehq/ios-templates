# Async Testing

## When to use this reference

Use when tests involve `async/await` functions, completion handlers, event streams, or timing-related concerns.

## Async test functions

Simply mark the test function `async` and `await` directly. No special base class needed (unlike Quick's `AsyncSpec`).

```swift
@Test("fetches the user profile")
func fetchesTheUserProfile() async throws {
    let client = APIClient(network: StubNetworkAPI())
    let profile = try await client.fetchProfile()
    #expect(profile.name == "Antoine")
}
```

## Actor-isolated stubs

When the protocol requires `async` methods or manages mutable state, use a `private actor`:

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

Use `private struct` when the protocol does not require `async` or mutable state.

## Callback bridging

For completion-handler APIs without async overloads, bridge with continuations:

```swift
@Test("loads legacy data")
func loadsLegacyData() async throws {
    let value = try await withCheckedThrowingContinuation { continuation in
        legacyLoad { result in
            continuation.resume(with: result)
        }
    }
    #expect(value == 42)
}
```

## Confirmations for event delivery

Use `confirmation` when validating event delivery count:

```swift
@Test("publishes exactly two events")
func publishesExactlyTwoEvents() async {
    await confirmation("event published", expectedCount: 2) { confirm in
        confirm()
        confirm()
    }
}
```

Use `expectedCount: 1...` for "at least one" semantics.

## MainActor isolation

Only isolate to `@MainActor` when behavior truly requires main-thread access:

```swift
@MainActor
@Test("updates the view model on main thread")
func updatesTheViewModelOnMainThread() {
    let viewModel = HomeViewModel()
    viewModel.refresh()
    #expect(viewModel.isLoading == true)
}
```

Keep non-UI tests off the main actor for realistic concurrency and better parallelization.

## Migration from Quick AsyncSpec

Before (Quick + Nimble):

```swift
final class NetworkAPISpec: AsyncSpec {
    override class func spec() {
        describe("its performRequest") {
            context("when network returns value") {
                it("returns message as Hello") {
                    let response = try await networkAPI.performRequest(config, for: Model.self)
                    expect(response.message) == "Hello"
                }
            }
        }
    }
}
```

After (Swift Testing):

```swift
@Suite("NetworkAPI")
struct NetworkAPITests {

    @Test("returns the response when network succeeds")
    func returnsTheResponseWhenNetworkSucceeds() async throws {
        let networkAPI = NetworkAPI()
        NetworkStubber.addStub(requestConfiguration)

        let response = try await networkAPI.performRequest(
            requestConfiguration,
            for: DummyNetworkModel.self
        )

        #expect(response.message == "Hello")
        NetworkStubber.removeAllStubs()
    }
}
```

## Anti-patterns

- **Don't** use `Task.sleep` as synchronization — use awaitable conditions.
- **Don't** mark tests `async` if the code under test is synchronous.
- **Don't** use mutable shared counters in callback closures — use actor-isolated state or confirmations.
