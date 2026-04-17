---
name: swift6-concurrency
description: >
  Write, review, or fix Swift 6 concurrency code using actors, Sendable, structured concurrency,
  and the strict data-race-safety model. Use when working with async/await, actors, data race
  compiler errors, Sendable conformance, TaskGroup, AsyncSequence, or migrating Swift 5 code
  to Swift 6 strict concurrency. Triggers on: "actor", "Sendable", "data race", "MainActor",
  "async let", "TaskGroup", "AsyncStream", "concurrency warning", "strict concurrency",
  "Swift 6 concurrency", "nonisolated", "Mutex".
---

# Swift 6 Concurrency

## Overview

Write, review, and fix Swift 6 concurrency code in this iOS project. Swift 6 enforces complete data race safety at compile time — every piece of mutable state that crosses a concurrency domain boundary must be protected by actors, `Sendable` conformance, or `Mutex`. This skill applies to all modules: App, Data, Domain, and Model.

## Agent Behavior Contract

1. **Never suppress concurrency errors with `nonisolated(unsafe)` without explicit user approval.** Investigate and fix the isolation root cause first.
2. **In async contexts, `actor` is the default for shared mutable state.** In synchronous contexts, prefer refactoring to async and using an `actor`; reach for `Mutex` (from `Synchronization`) only when async refactoring is not feasible, the critical section has no `await`, or fine-grained locking over a single value is needed.
3. **Use `@MainActor` for all UI-bound state.** Apply it to `ObservableObject` view models and `@Observable` types that drive the view hierarchy.
4. **Prefer structured concurrency** (`async let`, `TaskGroup`) over unstructured `Task { }`. Attach work to a parent task whenever possible.
5. **Mark types `Sendable` explicitly** when they cross isolation boundaries. Prefer value types (`struct`, `enum`) — they are implicitly `Sendable` when all stored properties are `Sendable`.
6. **Propagate task cancellation.** Check `Task.isCancelled` or call `try Task.checkCancellation()` inside loops or long-running operations.
7. **Avoid `@unchecked Sendable`** unless integrating a third-party type that is thread-safe but lacks annotation. Always add a comment explaining why it is safe.
8. **Use `@preconcurrency import`** when adopting a framework not yet fully annotated for Swift 6, to suppress false-positive warnings at the boundary.
9. **No `DispatchQueue` in new Swift 6 code.** Use `actor` for shared mutable state. `Mutex` is acceptable for short synchronous critical sections, but never as a default replacement for actors.
10. **Never call `MainActor.assumeIsolated`** outside of truly non-async contexts (e.g., UIKit delegate callbacks). In async code, just annotate or `await MainActor.run { }`.

## Quick Triage

Before writing or reviewing concurrency code, clarify:

1. **Which isolation domain?** Main actor (UI), custom actor (domain/data service), or nonisolated?
2. **What mutability pattern?** Value type passed by copy, reference type shared by reference, or actor-protected state?
3. **Structured or unstructured?** Is there a parent `async` context to attach the child task to?
4. **Concurrency mode?** Check `SWIFT_STRICT_CONCURRENCY` in build settings — `complete` is Swift 6 mode.

## Canonical Patterns

### Actor protecting shared mutable state

```swift
actor TokenStore {

    private var accessToken: String?
    private var refreshToken: String?

    func store(access: String, refresh: String) {
        accessToken = access
        refreshToken = refresh
    }

    func retrieveAccessToken() -> String? {
        accessToken
    }
}
```

### `@MainActor` view model

```swift
@MainActor
final class HomeViewModel: ObservableObject {

    @Published private(set) var items: [HomeItem] = []
    @Published private(set) var isLoading = false

    private let repository: any HomeRepository

    init(repository: some HomeRepository) {
        self.repository = repository
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            items = try await repository.fetchItems()
        } catch {
            items = []
        }
    }
}
```

### Structured concurrency with `async let`

```swift
func loadDashboard() async throws -> Dashboard {
    async let user = userRepository.fetchCurrentUser()
    async let orders = orderRepository.fetchRecentOrders()
    async let banners = bannerRepository.fetchActiveBanners()

    return try await Dashboard(
        user: user,
        orders: orders,
        banners: banners
    )
}
```

### `TaskGroup` for dynamic fan-out

```swift
func fetchDetails(for ids: [String]) async throws -> [ItemDetail] {
    try await withThrowingTaskGroup(of: ItemDetail.self) { group in
        for id in ids {
            group.addTask {
                try await self.repository.fetchDetail(id: id)
            }
        }
        return try await group.reduce(into: []) { $0.append($1) }
    }
}
```

### `Mutex` for synchronous shared state (no async)

```swift
import Synchronization

final class RequestCounter: Sendable {

    private let _count = Mutex(0)

    func increment() {
        _count.withLock { $0 += 1 }
    }

    var count: Int {
        _count.withLock { $0 }
    }
}
```

## Routing to References

Load the appropriate reference file based on the task:

| Task | Reference |
|------|-----------|
| Actor design, actor isolation, `nonisolated`, global actors | `references/actors.md` |
| `Sendable`, `@Sendable` closures, crossing isolation boundaries | `references/sendability.md` |
| `async let`, `Task`, `TaskGroup`, task cancellation | `references/structured-concurrency.md` |
| `AsyncSequence`, `AsyncStream`, `for await` loops | `references/async-sequences.md` |

## Verification Checklist

Before finishing, confirm:

- [ ] All mutable state shared across concurrency domains is actor-isolated or `Sendable`
- [ ] `@MainActor` is applied to all `ObservableObject` / `@Observable` view models
- [ ] `async let` or `TaskGroup` used instead of a chain of sequential `await` calls where parallelism is possible
- [ ] No `Task.detached` unless genuinely required — if used, explain why in a comment
- [ ] Long loops call `try Task.checkCancellation()` at each iteration
- [ ] `Mutex` only used when the critical section is short, purely synchronous, and has no `await` — actor is the default otherwise
- [ ] `AsyncStream` / `AsyncThrowingStream` continuations call `.finish()` in all exit paths including errors
- [ ] No `DispatchQueue` in new code
- [ ] `nonisolated(unsafe)` absent (or signed off by the user with a safety comment)
