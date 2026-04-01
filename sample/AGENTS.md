# AGENTS.md

You are an experienced iOS developer working on **Sample**, a SwiftUI-based iOS application.

Source of truth for iOS conventions: Nimble Compass iOS guide
`https://nimblehq.co/compass/development/ios/`

If anything conflicts, prefer:
1) **Compass** (link above), then
2) **This `AGENTS.md`** (authoritative actionable rules).

## Technology stack

| Category | Technology |
|----------|------------|
| **Language** | Swift |
| **UI framework** | SwiftUI only |
| **Architecture** | Clean layering (app → domain ← data), modularized with SPM targets |
| **Dependency manager** | Swift Package Manager |
| **Automation** | Fastlane **Swift DSL** (`fastlane/Fastfile.swift`) |
| **Static analysis** | SwiftLint |

## Repo layout

```text
Modules/                    → SPM modules
  Domain/                   → Entities, interfaces, use cases (pure Swift)
  Data/                     → Networking, repositories, storage
Sample/             → App sources
SampleTests/        → Unit tests (Swift Testing)
SampleUITests/      → UI tests (XCTest / XCUITest)
fastlane/                   → Fastlane Swift DSL lanes/helpers
```

## Prerequisites

- Xcode (latest stable unless project constraints say otherwise)
- Ruby + Bundler (for running fastlane via `bundle exec`)
- SwiftLint available in your environment

## Testing expectations

```bash
swiftlint
bundle exec fastlane buildAndTest
```

You don’t need to run this on every small commit; rely on CI where available or run locally before merging substantial changes.

## Distribution lanes (CI/CD, not triggered by agents directly)

```bash
bundle exec fastlane buildAdHocStagingLane
bundle exec fastlane buildAdHocProductionLane
bundle exec fastlane buildStagingAndUploadToFirebaseLane
bundle exec fastlane buildProductionAndUploadToFirebaseLane
bundle exec fastlane buildAndUploadToTestFlightLane
bundle exec fastlane buildAndUploadToAppStoreLane
```

Distribution targets: Firebase Distribution (staging/QA), TestFlight (beta), App Store (production). Code signing is managed via `match`.

## Project structure

Keep file organization aligned to our internal standard in **[Standard-File-Organization.md](.github/wiki/Standard-File-Organization.md)**.

Key rules:
- `Sources/` for Swift only; `Resources/` for assets/strings/fonts/plists; `Configurations/` for xcconfigs/entitlements
- Domain stays **pure Swift** (no UI/framework dependencies)
- SwiftUI only — do not introduce UIKit

### `Modules/` (SPM targets)

- `Domain/` — entities, interfaces, use cases; keep framework-light
- `Data/` — `NetworkAPI/` (interceptors, models, request configs), `Repositories/`

### `Sample/Sources/`

- `Application/` — `SampleApp.swift`, `AppDelegate.swift`
- `Constants/` — `Constants.swift`, `Constants+API.swift`
- `Presentation/`
  - `Models/`, `Coordinators/`, `Modules/`, `Styles/`, `ViewModifiers/`, `Views/`, `ViewIds/`
- `Supports/`
  - `Extensions/` (grouped by framework, e.g. `Foundation/`, `SwiftUI/`)

## Architecture

Maintain the intended separation:
- **Domain**: interfaces + business logic only
- **Data**: implementations (networking/storage) satisfying Domain interfaces
- **App**: UI and composition root

When adding new functionality: introduce a **Domain interface / use case** first, implement it in Data, then wire it up in App.

## Tests

- Unit and integration-style tests: **Swift Testing** in `SampleTests/` and module test targets (`DomainTests`, `DataTests`).
- UI and performance tests: **XCTest / XCUITest** in `SampleUITests/`.
- The sample does **not** ship Quick, Nimble, or KIF-driven UI tests in its Xcode targets; keep tests deterministic, avoid real network calls, and use `OHHTTPStubs` for Data-layer stubbing.

## Build configurations

Four configurations: `Debug Staging`, `Debug Production`, `Release Staging`, `Release Production`.

XCConfig files live in `Sample/Configurations/XCConfigs/`. Compilation flags: `DEBUG`, `STAGING`, `PRODUCTION`.

## Configuration files (where to look)

| File / Path | Purpose |
|------------|---------|
| `.mise.toml` | Tool versions (xcbeautify, etc.) |
| `Package.swift` | SPM dependency declarations |
| `fastlane/Fastfile.swift` | Lane definitions (Swift DSL) |
| `fastlane/Constants/Constant.swift` | Project name, bundle IDs, device list, Firebase app IDs |
| `fastlane/Constants/Secret.swift` | CI-provided environment keys (no secrets in-repo) |
| `fastlane/Helpers/` | Manager classes: `Build.swift`, `Distribution.swift`, `Match.swift`, `Test.swift`, `Version.swift` |

## Boundaries

✅ **Required:**
- Keep Compass structure and naming conventions.
- Keep CI green.
- Keep Domain framework-light.

⚠️ **Be cautious when:**
- Changing fastlane lanes/signing/distribution behavior.

🚫 **Don't:**
- Hardcode credentials, signing materials, or secrets in the repo.
- Add files that violate the Compass structure (e.g. configs in `Sources/`, resources in `Sources/`).
- Introduce UIKit.
