# Actors

## When to use this reference

Use when needing to protect class-based mutable state from concurrent access, designing actor types, resolving actor isolation errors, working with global actors (`@MainActor`), or making protocol conformances work across isolation domains.

## What actors provide

An `actor` is a reference type that serializes access to its stored properties. The compiler guarantees:

- All reads and writes to actor-isolated state happen sequentially.
- Callers outside the actor must `await` to access isolated members.
- No two tasks can be inside the actor concurrently.

## Basic actor

```swift
actor SessionManager {

    private var isAuthenticated = false
    private(set) var userId: String?

    func logIn(userId: String) {
        isAuthenticated = true
        self.userId = userId
    }

    func logOut() {
        isAuthenticated = false
        userId = nil
    }
}
```

### Callers outside the actor:

```swift
let manager = SessionManager()
await manager.logIn(userId: "abc123")
print(await manager.userId) // Must await reads too
```

Always use await when accessing actor properties/methods—you don't know if another task is inside.

### Callers inside the actor (no `await` needed):

```swift
actor SessionManager {

    func reset() {
        logOut()           // No await — same isolation domain
    }
}
```

## Actors vs Classes

### Similarities

- Reference types (copies share same instance)
- Can have properties, methods, initializers
- Can conform to protocols

### Differences

- **No inheritance** (except `NSObject` for Objective-C interop)
- **Automatic isolation** (no manual locks needed)
- **Implicit Sendable** conformance

```swift
// ❌ Can't inherit from actors
actor Base {}
actor Child: Base {} // Error

// ✅ NSObject exception
actor Example: NSObject {} // OK for Objective-C
```

## `nonisolated` members

Use `nonisolated` for members that do not touch actor state — they can be called without `await`.

```swift
actor AnalyticsClient {

    private var eventLog: [String] = []

    nonisolated let serviceID: String   // Stored constant — safe to access without await

    init(serviceID: String) {
        self.serviceID = serviceID
    }

    func track(event: String) {
        eventLog.append(event)
    }
}

// Callers can read serviceID synchronously:
let id = analyticsClient.serviceID
```

Rules for `nonisolated`:
- Safe on `let` stored properties (immutable — no data race possible).
- Safe on computed properties and methods that only read immutable or `Sendable` values.
- **Never** apply `nonisolated` to a `var` stored property — the compiler will reject it.

## `nonisolated(unsafe)` — last resort

`nonisolated(unsafe)` opts a stored property out of actor isolation checking. Only use this as a compatibility escape hatch for types you cannot change, and always justify it:

```swift
actor LegacyBridge {

    // Safe: SDWebImageManager is internally thread-safe via its own locks.
    nonisolated(unsafe) let imageManager = SDWebImageManager.shared
}
```

If you find yourself reaching for `nonisolated(unsafe)` on your own types, redesign the isolation instead.

## Global actors

A global actor is a singleton actor that can be applied to types, methods, and properties with an attribute.

### `@MainActor`

The built-in global actor that represents the main thread. Apply it to anything that must run on the main thread.

```swift
@MainActor
final class CartViewModel: ObservableObject {

    @Published private(set) var itemCount = 0
}
```

```swift
@MainActor
func updateBadge(count: Int) {
    tabBarItem.badgeValue = count > 0 ? "\(count)" : nil
}
```

Crossing into `@MainActor` from a non-isolated context:

```swift
func backgroundWork() async {
    let result = await heavyComputation()
    await MainActor.run {
        label.text = result   // Now on main thread
    }
}
```

### `@MainActor` Best Practices

### When to use

UI-related code that must run on main thread:

```swift
@MainActor
final class ContentViewModel: ObservableObject {
    @Published var items: [Item] = []
}
```

### Replacing DispatchQueue.main

```swift
// Old way
DispatchQueue.main.async {
    // Update UI
}

// Modern way
await MainActor.run {
    // Update UI
}

// Better: Use attribute
@MainActor
func updateUI() {
    // Automatically on main thread
}
```

### Custom global actor

Define a custom global actor when you want a domain-wide shared executor (e.g., a database queue).

```swift
@globalActor
actor DatabaseActor {

    static let shared = DatabaseActor()
}

@DatabaseActor
final class DatabaseService {

    func query(_ sql: String) -> [Row] { /* ... */ }
}
```

Use sparingly. Prefer injecting an actor instance over global actors for testability.

## Actor protocol conformance

When a protocol method must run on an actor, annotate the protocol requirement:

```swift
protocol DataRefreshable {

    func refresh() async
}

actor DataService: DataRefreshable {

    func refresh() async {
        // actor-isolated — safe to mutate state here
    }
}
```

When conforming to a protocol from a `@MainActor` type:

```swift
protocol Refreshable {

    @MainActor func refresh()
}

@MainActor
final class HomeViewModel: Refreshable {

    func refresh() { /* runs on main actor */ }
}
```

## Actor reentrancy

Actors are **reentrant** — while an `await` inside an actor is suspended, another caller can enter the actor and mutate state. Guard against this:

```swift
actor ImageCache {

    private var cache: [URL: UIImage] = [:]
    private var inflightRequests: Set<URL> = []

    func image(for url: URL) async throws -> UIImage {
        if let cached = cache[url] { return cached }

        // Check before suspending
        guard !inflightRequests.contains(url) else {
            // Wait or return a placeholder — don't start a duplicate request
            throw CacheError.requestInFlight
        }

        inflightRequests.insert(url)
        defer { inflightRequests.remove(url) }

        // Suspension point — another task may enter here
        let image = try await downloadImage(from: url)

        cache[url] = image
        return image
    }
}
```

Pattern: re-check invariants after every `await` inside an actor.

## Mutex: Alternative to Actors

`Mutex` (from `Synchronization`, requires iOS 18+ / macOS 15+) provides synchronous locking without async/await overhead.

```swift
import Synchronization

final class Counter: Sendable {

    private let count = Mutex<Int>(0)

    var currentCount: Int {
        count.withLock { $0 }
    }

    func increment() {
        count.withLock { $0 += 1 }
    }
}
```

`Mutex` also enables `Sendable` access to otherwise non-`Sendable` types:

```swift
final class TouchesCapturer: Sendable {

    let path = Mutex<NSBezierPath>(NSBezierPath())

    func storeTouch(_ point: NSPoint) {
        path.withLock { $0.move(to: point) }
    }
}
```

### Mutex vs Actor

| Feature | Mutex | Actor |
| ------- | ----- | ----- |
| Synchronous access | ✅ | ❌ (requires `await`) |
| Async support | ❌ | ✅ |
| Thread blocking | ✅ | ❌ (cooperative) |
| Fine-grained locking | ✅ | ❌ (whole actor at a time) |
| Legacy code integration | ✅ | ❌ |

**Use `Mutex` when:**

- Synchronous access is required (no `await` inside the critical section)
- Integrating with legacy non-async APIs
- Fine-grained locking over a single value is needed
- Contention is low and the critical section is short

**Use `actor` when:**

- Working in an async context and can use `await`
- Logical isolation of a domain or service is needed
- The critical section may itself need to `await`

### Decision tree

```text
Need thread-safe mutable state?
├─ Async context?
│  ├─ Single instance?       → actor
│  ├─ Global/shared?         → global actor (@MainActor or custom)
│  └─ UI-related?            → @MainActor
│
└─ Synchronous context?
   ├─ Can refactor to async?  → actor (preferred)
   ├─ Legacy code integration? → Mutex
   └─ Fine-grained locking?   → Mutex
```

## Do / Don't

- **Do** use actors for any reference type with mutable state accessed from multiple async contexts.
- **Do** use `nonisolated` on `let` constants and pure functions to avoid unnecessary `await` at call sites.
- **Do** re-check actor state after every `await` — reentrancy can change it.
- **Do** use `@MainActor` for all view models, UI updates.
- **Don't** put heavy synchronous work inside an actor — it blocks the actor's executor for other tasks.
- **Don't** use `nonisolated(unsafe)` on your own types without a thread-safety justification comment.
- **Don't** create a custom global actor when an injected actor instance would work — global actors are hard to test.
