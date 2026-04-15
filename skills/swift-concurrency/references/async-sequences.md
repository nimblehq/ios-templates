# Async Sequences

## When to use this reference

Use when producing or consuming streams of values over time: live data feeds, event publishers, socket streams, progress updates, or converting callback/delegate APIs to async sequences.

## `AsyncSequence` protocol

`AsyncSequence` is the async counterpart to `Sequence`. Consumers iterate it with `for await`:

```swift
for await event in analyticsStream {
    record(event)
}
```

The loop suspends between elements and exits when the sequence is exhausted or the task is cancelled.

## `AsyncStream` — continuation-based production

Use `AsyncStream` to bridge a callback or delegate API into an async sequence. No `throws`.

```swift
func locationUpdates() -> AsyncStream<CLLocation> {
    AsyncStream { continuation in
        let monitor = LocationMonitor()

        monitor.onUpdate = { location in
            continuation.yield(location)
        }

        monitor.onStop = {
            continuation.finish()
        }

        continuation.onTermination = { _ in
            monitor.stop()   // Clean up when consumer cancels or stream ends
        }

        monitor.start()
    }
}
```

Consuming:

```swift
for await location in locationUpdates() {
    updateMap(location)
}
```

### Buffering strategy

Control how the stream handles back-pressure:

```swift
AsyncStream(bufferingPolicy: .bufferingNewest(10)) { continuation in
    // Keeps the 10 most recent values if the consumer is slow
}
```

| Policy | Behaviour |
|--------|-----------|
| `.unbounded` | Buffer everything (default) — risk of unbounded memory growth |
| `.bufferingNewest(n)` | Keep only the newest `n` pending values; drop older ones |
| `.bufferingOldest(n)` | Keep only the oldest `n` pending values; drop newer ones |

Prefer `.bufferingNewest` for UI event streams where only the latest value matters.

## `AsyncThrowingStream` — failable streams

Use when the producer can fail (e.g., a network stream that disconnects):

```swift
func fetchEventStream(url: URL) -> AsyncThrowingStream<ServerEvent, Error> {
    AsyncThrowingStream { continuation in
        let task = Task {
            do {
                let (bytes, _) = try await URLSession.shared.bytes(from: url)
                for try await line in bytes.lines {
                    let event = try JSONDecoder().decode(ServerEvent.self, from: Data(line.utf8))
                    continuation.yield(event)
                }
                continuation.finish()
            } catch {
                continuation.finish(throwing: error)
            }
        }

        continuation.onTermination = { _ in task.cancel() }
    }
}
```

Consuming:

```swift
do {
    for try await event in fetchEventStream(url: streamURL) {
        handle(event)
    }
} catch {
    showError(error)
}
```

## Always call `finish()` in all exit paths

A stream that never calls `finish()` will stall its consumer indefinitely.

```swift
AsyncThrowingStream { continuation in
    do {
        let data = try await fetch()
        continuation.yield(data)
        continuation.finish()          // ✓ Normal exit
    } catch {
        continuation.finish(throwing: error)   // ✓ Error exit
    }
    // If there were an early return path, finish() must appear there too
}
```

Use `defer` to guarantee finish:

```swift
AsyncThrowingStream { continuation in
    defer { continuation.finish() }

    guard let data = try? await fetch() else { return }
    continuation.yield(data)
}
```

## Transforming sequences

Use the standard `AsyncSequence` operators:

```swift
let filtered = locationUpdates()
    .filter { $0.horizontalAccuracy < 20 }

let mapped = orderUpdates()
    .map { OrderSummary(from: $0) }

let first = try await statusUpdates().first(where: { $0 == .completed })
```

## Consuming with task cancellation

The `for await` loop automatically stops when the enclosing task is cancelled and the sequence propagates cancellation. For sequences backed by `AsyncStream`, set `onTermination` to release resources:

```swift
continuation.onTermination = { @Sendable _ in
    webSocketTask.cancel(with: .goingAway, reason: nil)
}
```

The `@Sendable` annotation on the closure is required because `onTermination` can be called from any concurrency domain.

## Converting `Combine` publishers to `AsyncSequence`

Use `.values` on any `Publisher` to get an `AsyncPublisher`:

```swift
for await value in publisher.values {
    handle(value)
}
```

Prefer `AsyncStream` for new code. Use `.values` only when bridging an existing `Combine` pipeline.

## Pattern: actor-owned stream producer

Encapsulate stream production inside an actor to protect the continuation:

```swift
actor OrderTracker {

    private var continuation: AsyncStream<OrderStatus>.Continuation?

    lazy var statusStream: AsyncStream<OrderStatus> = {
        AsyncStream { continuation in
            self.continuation = continuation
            continuation.onTermination = { @Sendable [weak self] _ in
                Task { await self?.invalidate() }
            }
        }
    }()

    func update(status: OrderStatus) {
        continuation?.yield(status)
    }

    func invalidate() {
        continuation?.finish()
        continuation = nil
    }
}
```

## Do / Don't

- **Do** call `continuation.finish()` (or `finish(throwing:)`) in every exit path — missing it stalls the consumer.
- **Do** set `onTermination` to release resources (network connections, observers, timers) when the consumer cancels.
- **Do** choose a buffering policy — leaving it at `.unbounded` in a high-frequency stream can grow memory without bound.
- **Do** annotate `onTermination` closures with `@Sendable` — the runtime can call them from any isolation domain.
- **Don't** store a raw `AsyncStream.Continuation` in a non-actor type without synchronization — wrap it in an actor.
- **Don't** `for await` without task-cancellation awareness — ensure the producer can stop cleanly when the task is cancelled.
- **Don't** use `AsyncStream` when a simple `async` function returning a single value is sufficient.
