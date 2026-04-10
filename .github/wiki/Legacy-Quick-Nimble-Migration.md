## Legacy Quick Nimble Migration

This guide is only for projects generated from older template versions that still use Quick/Nimble.

The current template standard is documented in [[Testing]].

## Migration Direction

- Migrate unit and integration tests to **Swift Testing**.
- Keep UI and performance tests on **XCTest / XCUITest**.
- Rename `Spec` files and suite types to `Tests`.
- Remove `Specs/` directories in favor of feature-based folders or production-mirroring paths.

## Common Mappings

- `QuickSpec` / `AsyncSpec` → `struct ...Tests` with `@Suite` and `@Test`
- `describe`, `context`, `it` → named test functions or nested helper types when needed
- `expect(value) == otherValue` → `#expect(value == otherValue)`
- `expect(value).to(beNil())` → `#expect(value == nil)`
- `HomeViewModelSpec.swift` → `HomeViewModelTests.swift`
- `Tests/Sources/Specs/<Feature>/...` → `Tests/Sources/<Feature>/...`

## Practical Approach

- Migrate feature-by-feature instead of rewriting every legacy test at once.
- Remove Quick and Nimble dependencies only after the remaining suites are converted.
- Update wiki/docs in the same pull request so new code does not reintroduce legacy conventions.
