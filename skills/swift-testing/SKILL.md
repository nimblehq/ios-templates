---
name: swift-testing
description: >
  Write, review, or migrate unit tests using Swift Testing (@Test, @Suite, #expect, #require).
  Use when writing new tests, converting existing Quick+Nimble specs to Swift Testing,
  reviewing test quality, debugging flaky tests, or improving test structure in this iOS
  template project. Triggers on: "write test", "add test", "test this", "migrate test",
  "convert spec", "Swift Testing".
---

# Swift Testing

## Overview

Write, review, migrate, and debug tests using Swift Testing for this iOS template project. This project uses **Quick + Nimble** (`*Spec.swift`) as the legacy framework and **Swift Testing** (`*Tests.swift`) for all new tests.

## Agent Behavior Contract

1. **Swift Testing for all new unit/integration tests.** Retain Quick+Nimble only for existing specs; do not migrate unless asked.
2. Use `#expect` as the default assertion; use `#require` only when subsequent lines depend on a prerequisite value.
3. Design tests to run safely in parallel by default. Fix shared state before reaching for `.serialized`.
4. Use inline `private struct` / `private actor` stubs conforming to domain protocols — no generated mocks.
5. Use `actor` stubs when the protocol requires `async` or has mutable state; use `struct` stubs otherwise.
6. Prefer parameterized tests (`@Test(arguments:)`) over duplicated test methods.
7. Use traits (`.enabled`, `.disabled`, `.timeLimit`, `.bug`, `.tags`) instead of ad-hoc comments.
8. Import `Testing` only in test targets, never in app/library targets.
9. Keep tests deterministic — no real network calls. Use `NetworkStubber` (OHHTTPStubs) for network-level tests.

## Quick Triage

Before writing or reviewing tests, clarify:

1. **New or migration?** Writing fresh tests vs converting an existing `*Spec.swift`.
2. **Which module?** App (`{PROJECT_NAME}Tests/`), Data (`Modules/Data/Tests/`), Domain (`Modules/Domain/Tests/`), or Model (`Modules/Model/Tests/`).
3. **Async?** Does the code under test use `async/await`?
4. **Shared resources?** Database, network, file system, or singleton state involved?

## File Naming & Placement

| Framework | Suffix | Placement |
|-----------|--------|-----------|
| Swift Testing | `*Tests.swift` | `Tests/Sources/` mirroring production path (e.g. `Repositories/`, `Entities/`) |
| Quick + Nimble | `*Spec.swift` | `Tests/Sources/Specs/` |

## Canonical Pattern (this project)

```swift
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
```

Key observations:
- `struct` suite, not `class`
- `@Suite("DisplayName")` with human-readable name matching the type under test
- `@Test("description")` with lowercase sentence describing behavior
- Function name is camelCase matching the description (no `test` prefix)
- Arrange / Act / Assert with blank line separations
- Inline `private actor` stub at bottom of file (actor because protocol has `async`)
- `@testable import` for the module under test; regular `import` for its dependencies

## Routing to References

Load the appropriate reference file based on the task:

| Task | Reference |
|------|-----------|
| Writing new tests, suite structure, naming | `references/fundamentals.md` |
| Assertions, error checking, known issues | `references/expectations.md` |
| Traits, tags, conditional execution | `references/traits-and-tags.md` |
| Data-driven / parameterized tests | `references/parameterized-testing.md` |
| Async/await, callbacks, confirmations | `references/async-testing.md` |
| Creating stubs, fakes, network mocks | `references/test-doubles.md` |
| Converting Quick+Nimble specs | `references/migration-from-quick-nimble.md` |

## Verification Checklist

Before finishing, confirm:

- [ ] Each test verifies one clear behavior
- [ ] `#require` is used for prerequisites; `#expect` for everything else
- [ ] Parameterized tests replace duplicated test methods
- [ ] Tests are parallel-safe (no shared mutable state)
- [ ] Async tests use `async` functions directly (no `Task.sleep` hacks)
- [ ] Stubs are `private struct` or `private actor` at bottom of file
- [ ] File is named `*Tests.swift` and placed in the correct module test directory
- [ ] No real network calls — `NetworkStubber` or protocol stubs used
