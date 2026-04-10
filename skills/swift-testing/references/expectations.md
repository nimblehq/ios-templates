# Expectations

## When to use this reference

Use when writing assertions, testing thrown errors, documenting known failures, or migrating from Nimble matchers.

## `#expect` — default assertion

Use `#expect` for most assertions. Pass natural Swift expressions.

```swift
#expect(total == 20)
#expect(total > 0)
#expect(items.contains("milk"))
#expect(name.isEmpty)
#expect(result != nil)
```

Swift Testing captures sub-expression values automatically for rich failure diagnostics.

## `#require` — prerequisite guard

Use `try #require(...)` when later assertions depend on this value. Stops the test early on failure.

```swift
@Test("parses a valid URL")
func parsesAValidURL() throws {
    let url = try #require(URL(string: "https://example.com"))
    #expect(url.scheme == "https")
    #expect(url.host == "example.com")
}
```

Use `#require` to unwrap optionals safely:

```swift
let firstItem = try #require(items.first, "Expected at least one item")
#expect(firstItem.name == "Coffee")
```

## Error expectations

### Verify any error is thrown

```swift
#expect(throws: (any Error).self) {
    try dangerousOperation()
}
```

### Verify a specific error type

```swift
#expect(throws: NetworkError.self) {
    try client.fetch(from: invalidURL)
}
```

### Verify a specific error value

```swift
#expect(throws: ValidationError.missingField("email")) {
    try form.validate()
}
```

### Verify no error is thrown

```swift
#expect(throws: Never.self) {
    try safeOperation()
}
```

## Known issues

Use `withKnownIssue` for temporary expected failures you still want to compile and run.

```swift
@Test("checkout completes")
func checkoutCompletes() async {
    #expect(cart.itemCount > 0)

    withKnownIssue("Payment gateway intermittently returns 503") {
        Issue.record("Known upstream issue")
    }
}
```

Remove `withKnownIssue` once the issue is fixed.

## `Issue.record` — manual failure

```swift
Issue.record("Unexpected state reached")
```

Replaces `XCTFail(...)` from XCTest and Nimble's `fail(...)`.

## Custom test descriptions

Conform complex types to `CustomTestStringConvertible` for concise failure output:

```swift
struct Receipt: CustomTestStringConvertible {
    let id: UUID
    let total: Decimal

    var testDescription: String {
        "Receipt(total: \(total))"
    }
}
```

## Nimble matcher mapping

| Nimble | Swift Testing |
|--------|--------------|
| `expect(x) == y` | `#expect(x == y)` |
| `expect(x) != y` | `#expect(x != y)` |
| `expect(x).to(beNil())` | `#expect(x == nil)` |
| `expect(x).toNot(beNil())` | `#expect(x != nil)` |
| `expect(x).to(beTrue())` | `#expect(x == true)` or `#expect(x)` |
| `expect(x).to(beFalse())` | `#expect(x == false)` or `#expect(!x)` |
| `expect(x).to(beGreaterThan(y))` | `#expect(x > y)` |
| `expect(x).to(contain(y))` | `#expect(x.contains(y))` |
| `expect(x).to(beEmpty())` | `#expect(x.isEmpty)` |
| `expect(x).to(haveCount(n))` | `#expect(x.count == n)` |
| `expect { ... }.to(throwError())` | `#expect(throws: (any Error).self) { ... }` |
| `await expect { ... }.to(throwError())` | `#expect(throws: (any Error).self) { try await ... }` |
| `expect(x).to(beCloseTo(y, within: 0.01))` | `#expect(abs(x - y) < 0.01)` |
| `fail("reason")` | `Issue.record("reason")` |

## Do / Don't

- **Do** use `#require` when later checks depend on a value.
- **Do** keep `withKnownIssue` scopes narrow.
- **Don't** use Nimble assertions in Swift Testing tests.
- **Don't** hide prerequisite failures inside optional chaining.
