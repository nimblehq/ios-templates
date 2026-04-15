# Structured Concurrency

## When to use this reference

Use when spawning concurrent work, running parallel async calls, managing task lifetimes, handling task cancellation, or choosing between structured (`async let`, `TaskGroup`) and unstructured (`Task`) concurrency.

## The structured concurrency hierarchy

In structured concurrency, child tasks:
- Are always tied to their parent's lifetime.
- Inherit the parent's priority and task-local values.
- Automatically cancel if the parent is cancelled or throws.
- Are always awaited before the parent returns.

Prefer structured forms (`async let`, `TaskGroup`) over `Task { }` (unstructured).

## `async let` — parallel independent calls

Use when you have a fixed number of independent async operations and want them to run concurrently.

```swift
func loadProductPage(id: String) async throws -> ProductPage {
    async let product = productRepository.fetch(id: id)
    async let reviews = reviewRepository.fetchReviews(productId: id)
    async let recommendations = recommendationRepository.fetch(productId: id)

    // All three run concurrently; awaited here
    return try await ProductPage(
        product: product,
        reviews: reviews,
        recommendations: recommendations
    )
}
```

Rules:
- `async let` bindings start immediately when declared.
- If one throws, the others are cancelled automatically.
- Must be `await`ed before the function returns (the compiler enforces this).

## `TaskGroup` — dynamic fan-out

Use when the number of concurrent operations is determined at runtime.

### Basic fan-out and collect

```swift
func prefetchImages(urls: [URL]) async -> [URL: UIImage] {
    await withTaskGroup(of: (URL, UIImage)?.self) { group in
        for url in urls {
            group.addTask {
                guard let image = try? await downloadImage(from: url) else { return nil }
                return (url, image)
            }
        }

        var result: [URL: UIImage] = [:]
        for await pair in group {
            if let (url, image) = pair {
                result[url] = image
            }
        }
        return result
    }
}
```

### Throwing fan-out

```swift
func fetchAll(ids: [String]) async throws -> [Detail] {
    try await withThrowingTaskGroup(of: Detail.self) { group in
        for id in ids {
            group.addTask { try await repository.fetchDetail(id: id) }
        }
        return try await group.reduce(into: []) { $0.append($1) }
    }
}
```

If any child task throws, the group cancels all remaining children and rethrows.

### `DiscardingTaskGroup` — fire-and-forget with backpressure

Use when results are not collected but you want bounded concurrency:

```swift
await withDiscardingTaskGroup { group in
    for event in eventStream {
        group.addTask { await process(event) }
    }
}
```

`DiscardingTaskGroup` discards child results as soon as they finish — lower memory overhead for large fan-outs.

## Unstructured tasks — `Task { }`

Use `Task { }` only when you genuinely cannot attach work to a parent async context (e.g., inside a `UIViewController` lifecycle method or a SwiftUI `.task` replacement).

```swift
// In a UIViewController — no async context available
override func viewDidLoad() {
    super.viewDidLoad()
    Task {
        await viewModel.load()
    }
}
```

Store the `Task` handle when you need to cancel it:

```swift
private var loadTask: Task<Void, Never>?

override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    loadTask?.cancel()
}

func beginLoad() {
    loadTask = Task { await viewModel.load() }
}
```

### `Task.detached` — avoid unless necessary

`Task.detached` does **not** inherit the parent's actor, priority, or task-locals. It truly detaches from the current context. Only use it when you explicitly want a lower-priority background task with no inherited context:

```swift
// Rare legitimate use: background index build that must not inherit @MainActor context
Task.detached(priority: .background) {
    await searchIndex.rebuild()
}
```

## Task cancellation

Swift concurrency uses cooperative cancellation — tasks must check for cancellation themselves.

### Checking cancellation

```swift
func processItems(_ items: [Item]) async throws {
    for item in items {
        try Task.checkCancellation()   // Throws CancellationError if cancelled
        await process(item)
    }
}
```

Or check without throwing:

```swift
guard !Task.isCancelled else { return }
```

### Propagating cancellation to child work

`async let` and `TaskGroup` child tasks are cancelled automatically when the parent is cancelled. For `URLSession`, cancellation is also propagated automatically.

For manual cleanup on cancellation:

```swift
func fetchWithCleanup() async throws -> Data {
    let task = Task {
        try await networkSession.data(from: url).0
    }

    do {
        return try await task.value
    } catch is CancellationError {
        await cleanup()
        throw CancellationError()
    }
}
```

### `withTaskCancellationHandler`

React synchronously to cancellation (e.g., to cancel a legacy callback API):

```swift
func fetchLegacy(url: URL) async throws -> Data {
    try await withTaskCancellationHandler {
        try await withCheckedThrowingContinuation { continuation in
            let request = legacySession.dataTask(with: url) { data, _, error in
                if let data { continuation.resume(returning: data) }
                else { continuation.resume(throwing: error ?? URLError(.unknown)) }
            }
            request.resume()
        }
    } onCancel: {
        // Called synchronously on cancellation
        request.cancel()   // Cancel the legacy task
    }
}
```

## Task priority

```swift
Task(priority: .userInitiated) { /* user-visible work */ }
Task(priority: .utility)       { /* background enrichment */ }
Task(priority: .background)    { /* prefetch / index */ }
```

Child tasks inherit the parent's priority unless overridden. `TaskGroup.addTask(priority:)` can lower priority for specific children.

## Task-local values

Propagate ambient context (e.g., request ID, logging context) without threading it through every function signature:

```swift
enum RequestContext {
    @TaskLocal static var requestId: String = "unknown"
}

func handleRequest(id: String) async {
    await RequestContext.$requestId.withValue(id) {
        await processSteps()   // All child tasks see id
    }
}

func processSteps() async {
    print(RequestContext.requestId)   // Reads inherited value
}
```

## Do / Don't

- **Do** use `async let` for a fixed set of parallel calls — it is the clearest and safest form.
- **Do** use `TaskGroup` when the count of parallel work items is dynamic.
- **Do** call `try Task.checkCancellation()` at the top of each loop iteration in long-running tasks.
- **Do** store `Task` handles from `Task { }` when you need to cancel them later (e.g., on view disappear).
- **Don't** use `Task.detached` unless you have an explicit reason to shed the parent context.
- **Don't** use `Task { }` inside an actor or `async` function when `async let` or `TaskGroup` would work.
- **Don't** swallow `CancellationError` — let it propagate unless you have explicit cleanup to perform.
