# AGENT.md

You are an experienced iOS developer working on an iOS **project template generator**.

Source of truth for iOS conventions: Nimble Compass iOS guide
`https://nimblehq.co/compass/development/ios/`

If anything here conflicts with `CLAUDE.md`, prefer:
1) **Compass** (link above), then
2) **This `AGENT.md`** (actionable rules), then
3) **`CLAUDE.md`** (repo overview and commands).

## Technology stack

| Category | Technology |
|----------|------------|
| **Language** | Swift |
| **UI frameworks** | SwiftUI + UIKit (template supports both) |
| **Architecture** | Clean-ish layering (app → domain ← data), modularized with SPM targets |
| **Dependency manager** | Swift Package Manager (and CocoaPods may appear in generated sample apps/CI) |
| **Project generation** | Tuist (managed via `.mise.toml`) |
| **Generator** | Swift CLI (`Scripts/Swift/iOSTemplateMaker`) |
| **Automation** | Fastlane **Swift DSL** (`fastlane/Fastfile.swift`) |
| **Static analysis** | SwiftLint |
| **CI/CD** | GitHub Actions (`.github/workflows/`), Bitrise (`bitrise.yml`), CodeMagic (`codemagic.yaml`) |

## Scope

This is an **iOS template repository**. Many files contain placeholders like `{PROJECT_NAME}` or `{ProjectName}` that are substituted during generation.

- Do not “fix” placeholders into concrete names unless you’re editing the generator that performs substitution.
- Prefer changes that preserve the template’s ability to generate both **SwiftUI** and **UIKit** variants when applicable.

## Repo layout (high-level)

```
Scripts/Swift/iOSTemplateMaker/  → Template generator CLI (Swift Package)
Modules/                        → SPM modules (Domain/Data)
{ProjectName}/                  → App template
{ProjectName}Tests/             → Unit tests template
{ProjectName}KIFUITests/        → UI tests template
fastlane/                       → Fastlane Swift DSL lanes/helpers
.github/                        → CI workflows + wiki docs under .github/wiki/
```

## Prerequisites

- Xcode (latest stable unless project constraints say otherwise)
- Ruby + Bundler (for running fastlane via `bundle exec`)
- Tuist (installed via `mise`; see `.mise.toml`)
- SwiftLint available in your environment (or via your team’s standard setup)

## Common commands

### Generate an Xcode project

```bash
tuist generate
```

### Install Ruby dependencies

```bash
bundle install
```

### Lint

```bash
swiftlint
```

### Run tests (Fastlane)

The canonical lane in this repo is `buildAndTest` (implemented as `buildAndTestLane()` in `fastlane/Fastfile.swift`).

```bash
bundle exec fastlane buildAndTest
```

### Generate a new project from the template

```bash
swift run --package-path Scripts/Swift/iOSTemplateMaker iOSTemplateMaker make \
  --bundle-id-production co.nimblehq.project \
  --bundle-id-staging co.nimblehq.project.staging \
  --project-name ProjectName \
  --interface SwiftUI
```

## Testing expectations

**Before commit (minimum):**

```bash
swiftlint
bundle exec fastlane buildAndTest
```

**After any template change:** verify the generator still works by generating a fresh project (into a temporary folder / clean workspace) and ensuring it builds/tests.

## Project structure (Compass-aligned)

Keep file organization aligned to the Compass structure.

### Root

- `README.md`
- `Modules/`
- `{ProjectName}/`
- `{ProjectName}Tests/`
- `{ProjectName}KIFUITests/` (or `{ProjectName}UITests` depending on template variant)

### `Modules/` (SPM targets)

- `Modules/Domain/`
  - `Sources/` contains **entities**, **interfaces**, **use cases**
  - `Tests/` contains unit tests and their resources/utilities
  - Keep Domain **pure Swift** (avoid UI/framework dependencies)
- `Modules/Data/`
  - `Sources/NetworkAPI/` (interceptors, models, request configurations, core)
  - `Sources/Repositories/`
  - `Tests/` mirrors the module structure with dummies/specs/utilities

### `{ProjectName}/`

- `Configurations/`
  - `Plists/`
  - `XCConfigs/`
- `Resources/`
  - `Assets/`
  - `Languages/`
  - `LaunchScreen/`
- `Sources/`
  - `Application/` (varies by UI interface)
  - `Constants/` (e.g. `Constants.swift`, `Constants+API.swift`)
  - `Presentations/` (varies by UI interface)
  - `Supports/`
    - `Builder/`
    - `Extensions/` (e.g. `Foundation/`, `UIKit/`)
    - `Helpers/` (e.g. `Typealias/`, `UIKit/`)

### SwiftUI-specific layout

When working in SwiftUI templates, prefer the Compass layout:

- `{ProjectName}/Sources/Application/` (`{ProjectName}App.swift`, `AppDelegate.swift`)
- `{ProjectName}/Sources/Presentation/`
  - `Models/`, `Coordinators/`, `Modules/`, `Styles/`, `ViewModifiers/`, `Views/`, `ViewIds/`

### UIKit-specific layout

When working in UIKit templates, prefer the Compass layout:

- `{ProjectName}/Sources/Application/` (`AppDelegate.swift`, `Application.swift`, `SceneDelegate.swift`)
- `{ProjectName}/Sources/Presentation/`
  - `Modules/`, `Navigator/`, `Views/`, `ViewIds/`

## Conventions for changes

### File placement rules

- **Swift source** goes under `Sources/` only.
- **Resources** (`.plist`, `.json`, fonts, storyboards, `.strings`, certificates, etc.) go under `Resources/` only.
- **Configs** (`Info.plist`, `.xcconfig`, entitlements) go under `Configurations/` only.
- Tests go under the appropriate test target folder and mirror the production folder structure when sensible.

### Naming & organization

- Prefer **clear, consistent grouping** by feature/module (e.g. `Presentation/Modules/<Feature>/...`).
- Avoid “misc” buckets; if you need a shared component, place it where other shared components live in the template (typically under `Supports/` or shared `Presentation` folders depending on UI framework).

### Architecture expectations (template-safe)

- Maintain the intended separation:
  - **Domain**: interfaces + business logic
  - **Data**: implementations (networking/storage) that satisfy Domain interfaces
  - **App**: UI and composition
- When adding new functionality, prefer introducing it first as a **Domain interface / use case**, then implement it in Data, then wire it in App.

## Tests

Follow the template’s testing style and directory expectations:

- Unit tests live in `{ProjectName}Tests/` (Quick + Nimble in this repo’s default setup).
- UI tests live in `{ProjectName}KIFUITests/` and follow the Compass-like grouping:
  - `AccessibilityIdentifiers/`, `Flows/`, `Screens/`, `Specs/`, `Utilities/`

Keep tests deterministic and avoid real network calls; use the repo’s established stubbing/mocking approach.

## Tooling & workflows (practical defaults)

- Project generation is Tuist-based; when changes affect project structure/manifests, assume `tuist generate` is required.
- Keep SwiftLint in mind; avoid introducing style regressions.
- CI is driven by GitHub Actions workflows under `.github/workflows/`.

## Documentation

- Prefer keeping template structure guidance in `.github/wiki/` (as already done) and keep `README.md` focused on “how to use the template.”
- When adding new folders or patterns that affect template consumers, update the relevant wiki doc (or add a new one) in `.github/wiki/`.

## Configuration files (where to look)

| File / Path | Purpose |
|------------|---------|
| `.mise.toml` | Tool versions (e.g. Tuist) |
| `Scripts/Swift/iOSTemplateMaker/Package.swift` | Generator SwiftPM package definition |
| `fastlane/Fastfile.swift` | Lanes (Swift DSL) |
| `fastlane/Constants/Constant.swift` | Template constants/placeholders for fastlane |
| `fastlane/Constants/Secret.swift` | CI-provided environment keys (no secrets in-repo) |
| `.github/workflows/*.yml` | GitHub Actions CI (PR checks, template install tests, etc.) |
| `bitrise.yml` | Bitrise pipelines (test, deploy staging/firebase, deploy App Store, etc.) |
| `codemagic.yaml` | CodeMagic workflows (test + deploy variants) |
| `.github/wiki/*` | Internal documentation for this template |

## CI/CD (summary)

- **GitHub Actions**: runs template install/build checks and PR workflows under `.github/workflows/`.
- **Bitrise** (`bitrise.yml`): includes `test`, `deploy_staging`, `deploy_release_firebase`, `deploy_app_store`.
- **CodeMagic** (`codemagic.yaml`): includes `test`, `deploy_staging_firebase`, `deploy_production_firebase`, `deploy_app_store`.

When changing build scripts, fastlane lanes, signing/distribution logic, or template structure, assume you must keep **all three** CI providers consistent unless the repo intentionally deprecates one.

## Template placeholders (do not “normalize”)

This repo uses placeholder tokens that are replaced during generation. **Do not replace them with real values** in the template.

Common examples found in-repo:

| Placeholder | Intended meaning |
|------------|------------------|
| `{PROJECT_NAME}` / `{ProjectName}` | App/project name |
| `{BUNDLE_ID_STAGING}` | Staging bundle identifier |
| `{BUNDLE_ID_PRODUCTION}` | Production bundle identifier |
| `{organization}` / `{repo}` | Match repo URL segments (code signing) |
| Swift “editor placeholders” like `<#...#>` | Values intentionally required from the team/user |

## Key guidelines for agents (iOS template specific)

1. **Template awareness**: preserve placeholder strings and generation-time substitutions.
2. **Compass-first structure**: new files must land in the Compass folder layout (Configs/Resources/Sources; Presentation breakdown by UI framework).
3. **Module boundaries**: Domain must stay framework-light; Data implements Domain; App composes UI + DI.
4. **Don’t break CI**: changes to fastlane/CI/generator require extra care; keep GitHub Actions/Bitrise/CodeMagic aligned.
5. **SwiftUI vs UIKit**: don’t “convert” UIKit template to SwiftUI (or vice versa); keep each variant idiomatic.

## Boundaries

✅ **Required:**
- Keep Compass structure and naming conventions.
- Keep placeholders intact.
- Keep CI green (GitHub Actions at minimum; Bitrise/CodeMagic when relevant).

⚠️ **Be cautious / minimize churn when:**
- Changing generator behavior in `Scripts/Swift/iOSTemplateMaker/`.
- Changing fastlane lanes/signing/distribution behavior.
- Changing Tuist project generation settings.

🚫 **Don’t:**
- Hardcode credentials, signing materials, or secrets in the repo.
- “Fix” template placeholders into real names/IDs inside the template.
- Add files to generated outputs that violate the Compass structure (e.g. configs in `Sources/`, resources in `Sources/`, etc.).
