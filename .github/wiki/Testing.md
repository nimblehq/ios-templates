## Testing

The template standard is:

- Use **Swift Testing** for unit and integration-style tests.
- Use **XCTest / XCUITest** for UI and performance tests.
- Name files and suites with `Tests`, not `Spec`.
- Organize test folders by feature or by mirroring production paths. Do not create new `Specs/` directories.

## Unit and Integration Tests

Place unit and integration tests in:

- `{ProjectName}Tests/`
- `Modules/<Module>/Tests/`

Use `Testing` imports, `@Suite`, `@Test`, and `#expect`.

Example:

```swift
import Testing

@Suite("Optional+Unwrap")
struct OptionalUnwrapTests {
    @Test("returns an empty string when the optional is nil")
    func returnsAnEmptyStringWhenTheOptionalIsNil() {
        let value: String? = nil
        #expect(value.string.isEmpty)
    }
}
```

## UI Tests

Place UI tests in `{ProjectName}UITests/` and write them with `XCTestCase` and `XCUIApplication`.

Example:

```swift
import XCTest

final class ApplicationUITests: XCTestCase {
    func testLaunchShowsHomeScreen() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Hello, world!"].waitForExistence(timeout: 5))
    }
}
```

## Naming and Structure

- Prefer `FeatureNameTests.swift` and `FeatureNameUITests.swift`.
- Prefer suite names like `FeatureNameTests` instead of `FeatureNameSpec`.
- Mirror production folders when it helps discoverability, especially for shared extensions and support code.
- Keep helper code in clearly named folders such as `Utilities/`, not generic `Specs/`.

## Legacy Projects

Older projects generated from previous template versions may still use Quick/Nimble. Keep that migration guidance in [[Legacy Quick Nimble Migration]] instead of mixing it into the main testing guide.
