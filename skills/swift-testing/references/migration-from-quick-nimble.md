# Migration from Quick + Nimble

## When to use this reference

Use when converting existing `*Spec.swift` (Quick + Nimble) files to Swift Testing `*Tests.swift` files.

## Strategy

- Migrate incrementally, one file at a time.
- Quick+Nimble and Swift Testing can coexist in the same test target.
- Do not migrate all specs at once — each migration is a reviewable commit.

## Practical migration order

1. Convert assertions: `expect(x) == y` to `#expect(x == y)`.
2. Replace `describe/context/it` structure with `@Suite` / `@Test`.
3. Replace `beforeEach`/`afterEach` with suite `init()` or inline setup.
4. Collapse repetitive `context/it` blocks into parameterized tests.
5. Add traits/tags where beneficial.
6. Rename file from `*Spec.swift` to `*Tests.swift`.

## Construct mapping

| Quick + Nimble | Swift Testing |
|---------------|---------------|
| `class FooSpec: QuickSpec` | `struct FooTests` |
| `class FooSpec: AsyncSpec` | `struct FooTests` (with `async` test functions) |
| `override class func spec()` | (not needed — tests are declared directly) |
| `describe("a Foo")` | `@Suite("Foo")` on the struct |
| `describe("its bar")` | Nested `@Suite("bar") struct Bar { }` |
| `context("when X")` | Nested `@Suite("when X") struct WhenX { }` or separate `@Test` |
| `it("does Y")` | `@Test("does Y") func doesY()` |
| `beforeEach { ... }` | Suite `init() { ... }` |
| `afterEach { ... }` | `deinit` (class suite) or inline cleanup |
| `expect(x) == y` | `#expect(x == y)` |
| `expect(x).to(beNil())` | `#expect(x == nil)` |
| `expect(x).toNot(beNil())` | `#expect(x != nil)` |
| `expect(x).to(beTrue())` | `#expect(x == true)` |
| `expect(x).to(beEmpty())` | `#expect(x.isEmpty)` |
| `expect(x).to(contain(y))` | `#expect(x.contains(y))` |
| `expect(x).to(haveCount(n))` | `#expect(x.count == n)` |
| `expect { }.to(throwError())` | `#expect(throws: (any Error).self) { }` |
| `await expect { }.to(throwError())` | `#expect(throws: (any Error).self) { try await ... }` |
| `fail("reason")` | `Issue.record("reason")` |

## Full example: NetworkAPISpec migration

### Before (Quick + Nimble)

```swift
import Foundation
import Nimble
import Quick

@testable import Data

final class NetworkAPISpec: AsyncSpec {

    override class func spec() {

        describe("a NetworkAPI") {

            var networkAPI: NetworkAPI!
            var requestConfiguration: DummyRequestConfiguration!

            describe("its performRequest") {

                beforeEach {
                    requestConfiguration = DummyRequestConfiguration()
                }

                afterEach {
                    NetworkStubber.removeAllStubs()
                }

                context("when network returns value") {

                    beforeEach {
                        NetworkStubber.addStub(requestConfiguration)
                        networkAPI = NetworkAPI()
                    }

                    it("returns message as Hello") {
                        let response = try await networkAPI.performRequest(
                            requestConfiguration,
                            for: DummyNetworkModel.self
                        )
                        expect(response.message) == "Hello"
                    }
                }

                context("when network returns error") {

                    beforeEach {
                        NetworkStubber.addStub(requestConfiguration, data: Foundation.Data(), statusCode: 400)
                        networkAPI = NetworkAPI()
                    }

                    it("throws error") {
                        await expect {
                            try await networkAPI.performRequest(
                                requestConfiguration,
                                for: DummyNetworkModel.self
                            )
                        }.to(throwError())
                    }
                }
            }
        }
    }
}
```

### After (Swift Testing)

```swift
import Foundation
import Testing

@testable import Data

@Suite("NetworkAPI")
struct NetworkAPITests {

    @Suite("performRequest")
    struct PerformRequest {

        @Test("returns the response when network succeeds")
        func returnsTheResponseWhenNetworkSucceeds() async throws {
            let requestConfiguration = DummyRequestConfiguration()
            NetworkStubber.addStub(requestConfiguration)
            defer { NetworkStubber.removeAllStubs() }
            let networkAPI = NetworkAPI()

            let response = try await networkAPI.performRequest(
                requestConfiguration,
                for: DummyNetworkModel.self
            )

            #expect(response.message == "Hello")
        }

        @Test("throws an error when network fails")
        func throwsAnErrorWhenNetworkFails() async {
            let requestConfiguration = DummyRequestConfiguration()
            NetworkStubber.addStub(requestConfiguration, data: Foundation.Data(), statusCode: 400)
            defer { NetworkStubber.removeAllStubs() }
            let networkAPI = NetworkAPI()

            #expect(throws: (any Error).self) {
                try await networkAPI.performRequest(
                    requestConfiguration,
                    for: DummyNetworkModel.self
                )
            }
        }
    }
}
```

Key changes:
- `AsyncSpec` class replaced with `struct` suite — no special base class needed.
- `describe/context/it` replaced with nested `@Suite` structs and `@Test` functions.
- `beforeEach` setup inlined into each test (struct suite gives fresh instance per test).
- `afterEach` cleanup replaced with `defer { NetworkStubber.removeAllStubs() }` right after `addStub` — ensures cleanup runs even if the test throws.
- `expect(x) == y` replaced with `#expect(x == y)`.
- `await expect { }.to(throwError())` replaced with `#expect(throws:) { try await ... }`.
- Mutable `var` declarations replaced with `let` inside each test.

## When NOT to flatten `context` into separate tests

If multiple contexts share the same assertion logic with different inputs, use parameterized tests instead of nested suites:

```swift
// Instead of nested suites for "when value is true" / "when value is false":
@Test("converts boolean remote config values", arguments: [
    (RemoteConfigStoredValue.string("true"), true),
    (.string("off"), false),
    (.int(1), true),
    (.double(0), false)
])
func convertsBooleanRemoteConfigValues(stored: RemoteConfigStoredValue, expected: Bool) {
    #expect(Bool.makeRemoteConfigValue(from: stored) == expected)
}
```

## Handling `beforeEach`/`afterEach`

| Pattern | Swift Testing equivalent |
|---------|------------------------|
| Simple property setup | Suite `init()` |
| Per-test setup with variations | Inline at top of each test |
| Cleanup / teardown | Inline at end of test, or `deinit` on class suite |
| Shared stub setup | Helper method on the suite |

## Common pitfalls

- **Marking every test `@MainActor`**: Quick tests defaulted to main actor-like behavior. Swift Testing runs on arbitrary tasks. Only add `@MainActor` when truly needed.
- **Keeping mutable `var` at suite level**: In Quick, mutable vars were reset by `beforeEach`. In Swift Testing structs, each test gets a fresh instance — prefer `let` in `init()` or inline.
- **Migrating all files at once**: Migrate one spec at a time for reviewable, testable commits.
