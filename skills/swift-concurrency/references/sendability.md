# Sendability

## When to use this reference

Use when a type needs to cross a concurrency domain boundary, fixing `Sendable`-related compiler errors, annotating `@Sendable` closures, or deciding how to make a type safe to share across tasks.

## What `Sendable` means

`Sendable` indicates a type is safe to share across isolation domains (actors, tasks, threads). The compiler verifies this at compile time in Swift 6 (`SWIFT_STRICT_CONCURRENCY = complete`).

A type is `Sendable` when:
- All its stored state is immutable, or
- All its stored state is itself `Sendable` and mutations are protected (e.g., inside an actor).

## Implicit `Sendable` — value types

`struct` and `enum` with all-`Sendable` stored properties are implicitly `Sendable`. No annotation needed.

```swift
// Implicitly Sendable — all properties are value types
struct OrderSummary {

    let orderId: String
    let total: Decimal
    let items: [OrderItem]   // OrderItem must also be Sendable
}

enum PaymentStatus {

    case pending
    case completed(transactionId: String)
    case failed(reason: String)
}
```

## Explicit `Sendable` conformance

Conform explicitly when the compiler cannot verify sendability automatically:

```swift
// All stored properties are Sendable — explicit conformance is redundant but documents intent
struct AuthToken: Sendable {

    let value: String
    let expiresAt: Date
}
```

For `final class` with immutable state only:

```swift
final class RemoteConfigKey<Value: Sendable>: Sendable {

    let name: String
    let defaultValue: Value

    init(name: String, defaultValue: Value) {
        self.name = name
        self.defaultValue = defaultValue
    }
}
```

## Actors are always `Sendable`

An `actor` implicitly conforms to `Sendable` — it protects its own state, so it is safe to pass across domains.

```swift
actor TokenStore: Sendable { /* implicit */ }

// Safe to pass across task boundaries
let store = TokenStore()
Task {
    await store.store(access: "...", refresh: "...")
}
```

## `@Sendable` closures

Mark a closure `@Sendable` when it will be called from a different concurrency domain (e.g., passed to `Task`, `TaskGroup.addTask`, or `DispatchQueue` replacements).

```swift
func schedule(work: @Sendable @escaping () async -> Void) {
    Task { await work() }
}
```

The compiler enforces that a `@Sendable` closure only captures `Sendable` values:

```swift
class NonSendableService { /* ... */ }

let service = NonSendableService()

// Error: capture of 'service' with non-Sendable type in @Sendable closure
Task {
    service.doWork()
}
```

Fix by making the service an actor, a value type, or passing `Sendable` data instead of the object.

## Crossing isolation boundaries

When passing a value from one isolation domain to another, it must be `Sendable`:

```swift
@MainActor
func handleResult(_ result: SearchResult) {
    self.results = [result]
}

// In a non-isolated async function:
func search(query: String) async {
    let result = try await searchService.search(query: query)
    // SearchResult must be Sendable to cross into @MainActor
    await handleResult(result)
}
```

If `SearchResult` is a `struct` with `Sendable` fields, this compiles. If it is a `class`, make it `final` and all-immutable, or convert it to a struct.

## `@unchecked Sendable` — escape hatch

Use `@unchecked Sendable` when a type is provably thread-safe but the compiler cannot verify it (e.g., a third-party class protected by its own internal lock).

```swift
// Safe: SDWebImageManager uses its own internal serial queue for all state access.
extension SDWebImageManager: @unchecked Sendable {}
```

Rules:
- Always add a comment explaining the thread-safety guarantee.
- Never use it on your own types — redesign for proper isolation instead.
- Prefer making your wrapper an actor over marking the wrapped type `@unchecked Sendable`.

## `sending` parameters (Swift 6.0+)

The `sending` annotation allows passing a non-`Sendable` value across an isolation boundary as a one-way transfer — the caller loses access after the call:

```swift
func process(order: sending Order) async {
    // order is now owned by this async context
    await persist(order)
}
```

Use `sending` to avoid requiring `Sendable` on domain model types that are only ever passed one way (never shared).

## Common patterns

### Domain model as struct (preferred)

```swift
// Sendable implicitly — all fields are value types
struct UserProfile {
    let id: String
    let name: String
    let avatarURL: URL?
}
```

### DTO bridging at the isolation boundary

Keep non-Sendable third-party model types inside their isolation domain; bridge to a `Sendable` struct at the boundary:

```swift
actor RealmDataSource {

    func fetchUser(id: String) async -> UserProfile {
        let realmUser = realm.object(ofType: RealmUser.self, forPrimaryKey: id)
        // Convert inside the actor before crossing the boundary
        return UserProfile(
            id: realmUser?.id ?? "",
            name: realmUser?.name ?? "",
            avatarURL: realmUser?.avatarURL.flatMap(URL.init)
        )
    }
}
```

## Do / Don't

- **Do** prefer `struct` and `enum` — they are `Sendable` for free when their properties are.
- **Do** make `class` types that cross boundaries `final` with only immutable stored properties.
- **Do** make `Sendable` class with all properties `Sendable`.
- **Do** convert to a `Sendable` struct at actor boundaries rather than marking reference types `@unchecked Sendable`.
- **Do** add a thread-safety comment whenever using `@unchecked Sendable`.
- **Don't** apply `@unchecked Sendable` to mutable reference types without lock-based protection.
- **Don't** ignore `Sendable` warnings in Swift 5 mode — they become errors in Swift 6.
