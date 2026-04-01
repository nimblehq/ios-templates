# Testing with Swift Testing and XCTest

This template recommends **Swift Testing** for unit and integration-style tests and **XCTest / XCUITest** for UI and performance tests. The **sample app** under `sample/` demonstrates that setup.

Many teams still write tests in a **Quick + Nimble** style (`describe` / `context` / `it`, `expect(…).to(…)`, `beforeEach` / `afterEach`, `QuickSpec` / `AsyncSpec`, `@MainActor` view model specs). The tables below map those **common BDD patterns** (as used in reference projects such as modular apps with `Modules/**/Tests/**/Specs/`) to Swift Testing so migrations stay readable and consistent.

**Authoritative API references:** [Swift Testing](https://developer.apple.com/documentation/testing), [XCTest](https://developer.apple.com/documentation/xctest). WWDC24: [Meet Swift Testing](https://developer.apple.com/videos/play/wwdc2024/10179/), [Go further with Swift Testing](https://developer.apple.com/videos/play/wwdc2024/10195/).

---

## Typical Quick + Nimble patterns (reference)

Patterns used in many Nimble/Quick codebases:

| Pattern | Role |
|--------|------|
| `final class FooSpec: QuickSpec` / `AsyncSpec` | One spec type per file (or feature), `override class func spec() { … }` |
| `describe("…")` | Group tests by type or feature (e.g. “A HomeViewModel”, “CustomURLCache”) |
| `context("…")` | Sub-group by scenario (“when network succeeds”, “Unauthorized user”) |
| `it("…")` | Single behavior or assertion group; readable sentence |
| `beforeEach` / `afterEach` | Per-suite or per-context setup/teardown (mocks, DI `Container` registration, `UserDefaults`) |
| `expect(a).to(equal(b))`, `beTrue()`, `beNil()`, etc. | Assertions |
| `await expect(…).toEventually(…)` | Async / main-actor expectations in `AsyncSpec` |
| Nested `func makeCache()` inside `spec()` | Local test helpers scoped to the file |
| `@MainActor` on `AsyncSpec` subclasses | View model / UI-related unit tests |
| `@testable import ModuleName` | Access internal types under test |

---

## What to use in this template (Swift Testing vs XCTest)

| Concern | Use |
|--------|-----|
| Unit tests, integration-style tests, pure Swift | **Swift Testing** (`import Testing`) |
| UI tests (`XCUIApplication`, gestures, screenshots) | **XCTest** / **XCUITest** |
| Performance metrics (`measure`) | **XCTest** |

Swift Testing and XCTest can coexist in one project; UI and performance stay on XCTest.

---

## Mapping Quick/Nimble → Swift Testing

| Quick / Nimble | Swift Testing |
|----------------|----------------|
| `describe("Subject") { }` | `@Suite("Subject")` on a `struct`, or a **display name** on a suite; nested types for nested groups |
| `context("…") { }` | Nested `struct` with `@Suite`, or separate `@Suite` types in the same file; optional **`.tags`** for filters |
| `it("does X") { }` | `@Test("does X") func …` |
| `expect(x).to(equal(y))` | `#expect(x == y)` |
| `expect(x).to(beNil())` | `#expect(x == nil)` or `let x = try #require(optional)` |
| `expect { … }.to(throwError())` | `await #expect(throws: …) { … }` |
| `beforeEach` | `init()` on a suite type (runs per test), or **inline setup** at the start of each `@Test` when isolation must be obvious |
| `afterEach` | `defer` in the test, or a small helper; use `deinit` sparingly |
| `AsyncSpec` + `async` `it` | `async` / `throws` on `@Test` functions |
| `@MainActor` spec class | `@MainActor` on the `@Suite` type or on individual `@Test` methods when needed |
| Local helpers `func makeCache()` | `private` / `fileprivate` functions, or `enum Namespace { static func makeCache() }` |

**Parameterized cases** (replace several similar `it` blocks):

```swift
@Test(arguments: [value1, value2, value3])
func behaviorHolds(for input: InputType) {
    #expect(…)
}
```

**Tags** (optional, for CI or filtering):

```swift
extension Tag {
    @Tag static var integration: Tag
}

@Test(.tags(.integration))
func networkRequestDecodesResponse() async throws { … }
```

---

## File and type naming

| Legacy (Quick) | Recommended (Swift Testing) |
|----------------|-----------------------------|
| `HomeViewModelSpec.swift` | `HomeViewModelTests.swift` or `HomeViewModelSwiftTestingTests.swift` |
| `final class HomeViewModelSpec: AsyncSpec` | `struct HomeViewModelTests { }` or `@Suite("HomeViewModel") struct …` |

Keep **folder layout** aligned with production: `Tests/Sources/Specs/<Feature>/` (or your module’s test layout) mirroring `Sources/`, per [[Standard File Organization]].

---

## Imports, mocks, and determinism

- Use **`@testable import <Module>`** for types under test where applicable.
- Prefer **mocks**, **dummy** fixtures, and **stubbed** I/O (e.g. `OHHTTPStubs` in Data tests in the sample app)—**no real network** in unit tests.
- Reset **`UserDefaults`** / DI containers between tests when old Quick specs used `afterEach` for that.

---

## XCTest (UI and performance)

- **UI test targets:** `XCTestCase`, `XCUIApplication`, `XCTAssert…`.
- Under **Swift 6** strict concurrency, UI test classes that use `XCUIApplication` are often marked **`@MainActor`** (see sample `ApplicationLaunchUITests`).

---

## Migration checklist (when porting a Quick spec)

1. Replace `QuickSpec` / `AsyncSpec` with a **`struct`** and `@Suite` / `@Test`.
2. Map **`describe` / `context`** to nested **`@Suite`** types or clear **`@Test`** titles.
3. Replace **`expect`** with **`#expect`** / **`#require`**.
4. Move **`beforeEach`** / **`afterEach`** into **`init`**, **`defer`**, or helpers.
5. Preserve **`@MainActor`** where the old spec was `@MainActor` + `AsyncSpec`.
6. Ensure the app target has **`ENABLE_TESTABILITY`** for Debug-style configs when using `@testable import`.

---

## Summary

- **Swift Testing** is the preferred default for **unit and integration-style** Swift tests in this template; mirror the **intent** of `describe` / `it` / `context` with **suites**, **clear names**, and **parameterized** tests where it helps.
- **XCTest** remains for **UI** and **performance** tests.
- The mapping above aligns **common Quick/Nimble habits** (from reference projects) with Swift Testing so generated apps and migrations stay consistent.
