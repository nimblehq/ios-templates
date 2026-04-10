# Traits and Tags

## When to use this reference

Use when controlling test execution behavior, linking bug context, or organizing tests for targeted runs and CI filtering.

## Trait categories

| Category | Traits |
|----------|--------|
| Informational | Display names, `.bug(...)`, `.tags(...)` |
| Conditional | `.enabled(if:)`, `.disabled(...)`, `@available` |
| Behavioral | `.timeLimit(...)`, `.serialized` |

## Basic examples

```swift
@Test("uploads complete quickly", .timeLimit(.seconds(10)))
func uploadWithinTimeLimit() async throws {
    // ...
}

@Test(.disabled("Flaky on CI while investigating"), .bug("https://github.com/org/repo/issues/42"))
func temporarilyDisabledTest() {
    // ...
}
```

## Conditions

```swift
enum Runtime {
    static let isCI = ProcessInfo.processInfo.environment["CI"] == "true"
}

@Test(.enabled(if: Runtime.isCI))
func ciOnlySmokeTest() {
    // ...
}
```

Use `.disabled("reason")` instead of commenting tests out. Include actionable reason text.

## Availability

Use `@available` on individual test functions for OS-gated behavior:

```swift
@available(iOS 18, *)
@Test("uses modern push payload")
func usesModernPushPayload() {
    // ...
}
```

Never annotate suite types with `@available`.

## Tags

Define custom tags for cross-suite grouping:

```swift
extension Tag {
    @Tag static var networking: Self
    @Tag static var regression: Self
}

@Suite(.tags(.networking))
struct APIClientTests {
    @Test("fetches user profile")
    func fetchesUserProfile() async throws { /* ... */ }
}

struct CheckoutTests {
    @Test("calculates order total", .tags(.regression))
    func calculatesOrderTotal() { /* ... */ }
}
```

Tags cascade from suites to contained tests.

## Do / Don't

- **Do** put shared tags at suite level.
- **Do** attach `.bug(...)` links for disabled tests or known failures.
- **Don't** use tags as a replacement for suite grouping.
- **Don't** use `.serialized` as a blanket reliability fix — isolate shared state first.
