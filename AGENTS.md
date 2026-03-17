# AGENTS.md

You are an experienced iOS developer working on an iOS **project template generator**.

Source of truth for iOS conventions: Nimble Compass iOS guide
`https://nimblehq.co/compass/development/ios/`

If anything conflicts, prefer:
1) **Compass** (link above), then
2) **This `AGENTS.md`** (authoritative actionable rules).

## Technology stack

| Category | Technology |
|----------|------------|
| **Language** | Swift |
| **UI frameworks** | SwiftUI only (UIKit scaffolding has been removed) |
| **Architecture** | Clean-ish layering (app → domain ← data), modularized with SPM targets |
| **Dependency manager** | Swift Package Manager only (CocoaPods has been removed) |
| **Project generation** | Tuist (managed via `.mise.toml`) |
| **Generator** | Swift CLI (`Scripts/Swift/iOSTemplateMaker`) |
| **Automation** | Fastlane **Swift DSL** (`fastlane/Fastfile.swift`) |
| **Static analysis** | SwiftLint |
| **CI/CD** | GitHub Actions (`.github/workflows/`), Bitrise (`bitrise.yml`), CodeMagic (`codemagic.yaml`) |

## Scope

This is an **iOS template repository**. Many files contain placeholders such as `{PROJECT_NAME}` that are replaced during generation.

- Do not “fix” placeholders into concrete names unless you’re editing the generator that performs substitution.
- The template generates **SwiftUI-only** projects; do not reintroduce UIKit scaffolding.

## Repo layout (high-level)

```text
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

## Development commands

### Generate an Xcode project

```bash
mise install
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
  --project-name ProjectName
```

## Testing expectations

**Before commit (minimum):**

```bash
swiftlint
bundle exec fastlane buildAndTest
```

**After any template change:** verify the generator still works by generating a fresh project (into a temporary folder / clean workspace) and ensuring it builds/tests.

## Project structure

Keep file organization aligned to [Standard-File-Organization.md](.github/wiki/Standard-File-Organization.md).

Key rules:
- Domain stays **pure Swift** (no UI/framework dependencies)
- `Sources/` for Swift only; `Resources/` for assets/strings/fonts/plists; `Configurations/` for xcconfigs/entitlements
- SwiftUI only — do not reintroduce UIKit scaffolding

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

Key wiki articles in `.github/wiki/`:
- `Getting-Started.md` — Full setup walkthrough
- `Fastlane.md` — All lanes and managers
- `Project-Configurations.md` — Build configs, xcconfig, compilation flags
- `Project-Dependencies.md` — Full dependency list
- `Standard-File-Organization.md` — File structure conventions

## Key dependencies

| Library | Version | Purpose |
|---------|---------|---------|
| Alamofire | 5.x | Networking |
| Factory | 2.x | Dependency injection |
| Kingfisher | 7.x | Image loading |
| KeychainAccess | 4.x | Secure storage |
| Firebase iOS SDK | 11.x | Crashlytics, Distribution |
| JSONMapper | 1.x | JSON mapping |
| Quick + Nimble | 7.x / 13.x | BDD unit testing |
| OHHTTPStubs | 9.x | Network mocking in tests |

## Build configurations

Four configurations: `Debug Staging`, `Debug Production`, `Release Staging`, `Release Production`. XCConfig files live in `{ProjectName}/Configurations/XCConfigs/`. Compilation flags: `DEBUG`, `STAGING`, `PRODUCTION`.

Tuist manifests in `Tuist/ProjectDescriptionHelpers/`:
- `BuildConfiguration.swift` — defines the four configurations
- `Target+Initializing.swift` — target definitions
- `Scheme+Initializing.swift` — scheme definitions
- `Module.swift` — Domain/Data module setup

## Configuration files (where to look)

| File / Path | Purpose |
|------------|---------|
| `.mise.toml` | Tool versions (Tuist 4.110.3, xcbeautify) |
| `Project.swift` | Root Tuist manifest (targets, schemes, packages) |
| `Package.swift` | SPM dependency declarations |
| `Tuist/ProjectDescriptionHelpers/` | Reusable Tuist helpers (see Build configurations above) |
| `Scripts/Swift/iOSTemplateMaker/Package.swift` | Generator SwiftPM package definition |
| `fastlane/Fastfile.swift` | Lane definitions (Swift DSL) |
| `fastlane/Constants/Constant.swift` | Project name, bundle IDs, device list, Firebase app IDs |
| `fastlane/Constants/Secret.swift` | CI-provided environment keys (no secrets in-repo) |
| `fastlane/Helpers/` | Manager classes: `Build.swift`, `Distribution.swift`, `Match.swift`, `Test.swift`, `Version.swift` |
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
| `{PROJECT_NAME}` | App/project name |
| `{BUNDLE_ID_STAGING}` | Staging bundle identifier |
| `{BUNDLE_ID_PRODUCTION}` | Production bundle identifier |
| `{organization}` / `{repo}` | Match repo URL segments (code signing) |
| Swift “editor placeholders” like `<#...#>` | Values intentionally required from the team/user |

## Key guidelines for agents (iOS template specific)

1. **Template awareness**: preserve placeholder strings and generation-time substitutions.
2. **Compass-first structure**: new files must land in the Compass folder layout (Configs/Resources/Sources; Presentation breakdown by UI framework).
3. **Module boundaries**: Domain must stay framework-light; Data implements Domain; App composes UI + DI.
4. **Don’t break CI**: changes to fastlane/CI/generator require extra care; keep GitHub Actions/Bitrise/CodeMagic aligned.
5. **SwiftUI only**: do not reintroduce UIKit scaffolding; the template is SwiftUI-only.

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
