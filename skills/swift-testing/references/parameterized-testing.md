# Parameterized Testing

## When to use this reference

Use when you have repeated tests with identical logic and only input changes.

## When to parameterize

Replace copy-pasted tests or in-test `for` loops with `@Test(arguments:)`. Each argument becomes its own independent test case with separate diagnostics and rerun capability.

## Single input collection

```swift
@Test("validates accepted age range", arguments: 18...21)
func validatesAcceptedAgeRange(_ age: Int) {
    #expect(isValidAge(age))
}
```

## Multiple inputs (cartesian product)

Two collections generate all combinations:

```swift
@Test("VAT invoice access", arguments: [Region.eu, .us], [Plan.free, .pro])
func vatInvoiceAccess(region: Region, plan: Plan) {
    let allowed = canUseVATInvoice(region: region, plan: plan)
    #expect((region == .eu && plan == .pro) == allowed)
}
```

## Paired inputs (recommended: array of tuples)

When inputs and expected outputs must be paired, use an array of tuples:

```swift
@Test("formats day labels", arguments: [
    (Day.monday, "Monday"),
    (.friday, "Friday"),
    (.sunday, "Sunday")
])
func formatsDayLabels(day: Day, expected: String) {
    #expect(format(day) == expected)
}
```

Prefer this over `zip` — pairs are co-located and impossible to misalign.

## `zip` for paired collections

Use only when inputs must remain as separate collections:

```swift
@Test("free try limits", arguments: zip([Tier.basic, .premium], [3, 10]))
func freeTryLimits(_ tier: Tier, expected: Int) {
    #expect(freeTries(for: tier) == expected)
}
```

**Caution:** `zip` silently truncates to the shorter collection. Prefer tuples or dictionaries.

## Replacing Quick+Nimble repetitive contexts

Before (Quick+Nimble):

```swift
describe("format") {
    context("when day is Monday") {
        it("returns Monday") {
            expect(format(.monday)) == "Monday"
        }
    }
    context("when day is Friday") {
        it("returns Friday") {
            expect(format(.friday)) == "Friday"
        }
    }
}
```

After (Swift Testing):

```swift
@Test("formats day correctly", arguments: [
    (Day.monday, "Monday"),
    (.friday, "Friday")
])
func formatsDayCorrectly(day: Day, expected: String) {
    #expect(format(day) == expected)
}
```

## Common pitfalls

- **Derived expected values masking bugs**: use concrete literals in `#expect`, not values derived from the input.
- **Control flow in test bodies**: `if`/`switch` mirrors implementation logic — split into separate tests instead.
- **Huge argument sets**: control explosion by reducing sets or splitting by concern.
- **Extracting argument arrays into separate properties**: keep arguments inline for readability.

## Do / Don't

- **Do** consolidate repetitive tests into parameterized tests.
- **Do** use concrete literal expectations.
- **Don't** use `if`/`switch` inside parameterized test bodies.
- **Don't** use `CaseIterable.allCases` with case-specific expected values — use explicit arrays.
