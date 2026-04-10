# Swift Testing Fundamentals

## When to use this reference

Use when writing new tests, organizing suites, or reviewing test structure and naming.

## Imports

```swift
import Testing

@testable import Data   // module under test
import Domain           // dependency (non-testable)
```

- Import `Testing` only in test targets.
- Use `@testable import` for the module under test; regular `import` for its public dependencies.

## `@Test` Macro

Declares a test function. No `test` prefix required.

```swift
@Test("returns the default value when key is missing")
func returnsTheDefaultValueWhenKeyIsMissing() {
    #expect(config.value(for: missingKey) == "default")
}
```

- Display name: lowercase sentence describing behavior.
- Function name: camelCase matching the display name.
- Mark `async` only if the code under test is async.
- Mark `throws` only if calling throwing code.

## `@Suite` Macro

Groups related tests into a struct (preferred), actor, or class.

```swift
@Suite("DefaultFeatureFlagRepository")
struct DefaultFeatureFlagRepositoryTests {

    @Test("reads feature flags through the remote config repository")
    func readsFeatureFlagsThroughTheRemoteConfigRepository() async {
        // ...
    }
}
```

- **Prefer `struct`** for value semantics and accidental-state-sharing prevention.
- Display name should match the type under test.
- Type name: `<TypeUnderTest>Tests`.

### Nested suites for grouping

Use nested structs to group by method or scenario:

```swift
@Suite("UserService")
struct UserServiceTests {

    @Suite("login")
    struct Login {

        @Test("succeeds with valid credentials")
        func succeedsWithValidCredentials() async throws { /* ... */ }

        @Test("fails with invalid password")
        func failsWithInvalidPassword() async { /* ... */ }
    }

    @Suite("logout")
    struct Logout {

        @Test("clears the session")
        func clearsTheSession() { /* ... */ }
    }
}
```

## Suite initialization (setup)

Use `init()` for shared setup across tests in a suite. Each test gets a fresh instance.

```swift
@Suite("TokenStore")
struct TokenStoreTests {

    let store: TokenStore

    init() {
        store = TokenStore(storage: InMemoryStorage())
    }

    @Test("stores a token")
    func storesAToken() { /* ... */ }
}
```

- No `beforeEach` / `afterEach` — the struct `init` replaces `beforeEach`.
- For teardown, use `deinit` on a `class` suite (rare; prefer stateless struct design).

## File placement (this project)

| Module | Test directory | Example |
|--------|---------------|---------|
| App | `{PROJECT_NAME}Tests/Sources/` | `Supports/Extensions/Foundation/OptionalUnwrapTests.swift` |
| Data | `Modules/Data/Tests/Sources/` | `Repositories/DefaultRemoteConfigRepositoryTests.swift` |
| Domain | `Modules/Domain/Tests/Sources/` | `Entities/RemoteConfigValueConvertibleTests.swift` |
| Model | `Modules/Model/Tests/Sources/` | (mirrors production path) |

Mirror the production source path. Place the test file in the same relative directory as the production file.

## Naming conventions

| Element | Convention | Example |
|---------|-----------|---------|
| File | `<TypeUnderTest>Tests.swift` | `DefaultFeatureFlagRepositoryTests.swift` |
| Suite | `@Suite("<TypeUnderTest>")` | `@Suite("DefaultFeatureFlagRepository")` |
| Struct | `<TypeUnderTest>Tests` | `struct DefaultFeatureFlagRepositoryTests` |
| Test | `@Test("lowercase behavior description")` | `@Test("falls back to the flag default value")` |
| Function | camelCase matching description | `func fallsBackToTheFlagDefaultValue()` |

## Do / Don't

- **Do** use `struct` suites for isolation between tests.
- **Do** write one behavior per test.
- **Do** use descriptive display names that read as sentences.
- **Don't** use `class` suites unless you need reference semantics or `deinit`.
- **Don't** depend on test execution order.
- **Don't** annotate suite types with `@available` — use it on individual `@Test` functions only.
