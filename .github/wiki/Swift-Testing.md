## Overview

New unit and integration tests use **Swift Testing** (`import Testing`).
Legacy Quick + Nimble guidance lives in [[Legacy Quick Nimble Migration]].

| Framework | File suffix | Location |
|-----------|------------|----------|
| Swift Testing | `*Tests.swift` | `Tests/Sources/` mirroring production path |

## File Placement

Mirror the production source path for the module under test:

| Module | Test directory |
|--------|---------------|
| App | `{PROJECT_NAME}Tests/Sources/` |
| Data | `Modules/Data/Tests/Sources/` |
| Domain | `Modules/Domain/Tests/Sources/` |
| Model | `Modules/Model/Tests/Sources/` |

## Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| File | `<TypeUnderTest>Tests.swift` | `DefaultFeatureFlagRepositoryTests.swift` |
| Suite type | `<TypeUnderTest>Tests` | `struct DefaultFeatureFlagRepositoryTests` |
| Suite display name | `@Suite("<TypeUnderTest>")` | `@Suite("DefaultFeatureFlagRepository")` |
| Test display name | `@Test("lowercase behavior sentence")` | `@Test("falls back to the flag default value")` |
| Test function | camelCase matching display name | `func fallsBackToTheFlagDefaultValue()` |

## Minimal Example

```swift
import Testing

@testable import Data
import Domain

@Suite("DefaultRemoteConfigRepository")
struct DefaultRemoteConfigRepositoryTests {

    @Test("returns a typed stored value")
    func returnsATypedStoredValue() async {
        let key = RemoteConfigKey(name: "feature_enabled", defaultValue: false)
        let repository = DefaultRemoteConfigRepository(
            source: StubRemoteConfigSource(values: [key.name: .string("true")])
        )

        let value = await repository.value(for: key)

        #expect(value == true)
    }
}

private actor StubRemoteConfigSource: RemoteConfigSource {
    private let values: [String: RemoteConfigStoredValue]
    init(values: [String: RemoteConfigStoredValue] = [:]) { self.values = values }
    func refresh() async throws {}
    func value(forKey key: String) async -> RemoteConfigStoredValue? { values[key] }
}
```

## Key Rules

- Use `#expect` by default; use `#require` only when subsequent lines depend on a non-nil or non-throwing prerequisite.
- Prefer `struct` suites — each test gets a fresh instance, preventing shared state.
- Use `init()` for setup; `deinit` on a `class` suite for teardown (rare).
- Tests run in parallel by default. Mark a suite `.serialized` only when it accesses global state (e.g. `NetworkStubber`).
- No real network calls — use `NetworkStubber` (OHHTTPStubs) or inline protocol stubs.
- Use `actor` stubs when the protocol has `async` members or mutable state; use `struct` otherwise.

## AI Skill

The `skills/swift-testing` agent skill provides detailed references for assertions, traits, parameterized tests, async testing, and test doubles:

```
skills/swift-testing/
├── SKILL.md
└── references/
    ├── fundamentals.md
    ├── expectations.md
    ├── traits-and-tags.md
    ├── parameterized-testing.md
    ├── async-testing.md
    └── test-doubles.md
```

For older projects still on Quick + Nimble, use [[Legacy Quick Nimble Migration]].
