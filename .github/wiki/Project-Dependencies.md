To simplify setup for developers new to the application and to ensure a system that runs reproducibly reliable builds. The creation and setup of a new project will be faster and safer. It will require only the language runtime (`Ruby 3.2+`) and the dependency manager installed as prerequisites.

The project normally contains:

- Fastlane: is the easiest way to automate beta deployments and releases for the `iOS` (also `Android`) applications. 🚀 It handles all tedious tasks, such as generating screenshots, dealing with code signing, and releasing the application.
- Swift Package Manager: the single source of truth for runtime dependencies. All shared libraries are declared in `Project.swift` and appear in Xcode's **Package Dependencies** section.

Current template toolchain support:

- Xcode `26+`
- Swift `6.1+`

## Dependencies

### Bundler

[Bundler](https://bundler.io/) is a Ruby package manager used for CLI tooling such as `fastlane`, `xcov`, and `danger`. Keeping package versions the same on all development machines and Continuous Development machines reduces unnoticed bugs from occurring.

The template now uses Ruby `3.2+` as its minimum baseline because `fastlane-plugin-firebase_app_distribution` `1.0.0` requires it. The repo exposes that baseline in both `.mise.toml` and `.ruby-version`.

### Fastlane

[Fastlane](https://fastlane.tools/) automates testing, builds, and, most importantly, certificates and profiles, which are core to the App Store ecosystem.

### Firebase

The main usage of [Firebase](https://firebase.google.com/) for our team is `Firebase Crashlytics` and `Firebase Distribution`. `Firebase Crashlytics` is used to track, prioritize, and fix stability issues that erode the app quality. `Firebase Distribution` is the primary method for QA and the Client to download applications for testing and presenting purposes. In some projects, `Firebase Analytics` is being used to track and analyze users' behavior for marketing purposes.

## Libraries

### Common

#### Alamofire

[Alamofire](https://github.com/Alamofire/Alamofire) is a networking library for Swift projects. It serves as the foundation for our networking layer, streamlining API calls across projects and enabling developers to switch between projects without friction.

#### JSONAPIMapper

[JSONAPIMapper](https://github.com/nimblehq/JSONMapper) works together with Alamofire to transform raw JSON responses into strongly typed models, keeping the networking layer predictable and easy to maintain.

### SwiftLint

[SwiftLint](https://github.com/realm/SwiftLint) is used to enforce our team's code convention. SwiftLint is the perfect tool for this task as it is customizable, lightweight, and automate-able. CI installs SwiftLint via Homebrew, and Danger runs it directly (no Pods required).

### KeychainAccess

[KeychainAccess](https://github.com/kishikawakatsumi/KeychainAccess) is a wrapper for Keychain, making storing data with Apple's encryption as convenient as using `UserDefault`.

#### Firebase (Crashlytics & Distribution)

The main usage of [Firebase](https://firebase.google.com/) for our team is `Firebase Crashlytics` and `Firebase Distribution`. `Firebase Crashlytics` is used to track, prioritize, and fix stability issues that erode the app quality. `Firebase Distribution` is the primary method for QA and Client to download applications for testing and presenting purposes. In some projects, `Firebase Analytics` is being used to track and analyze users' behavior for marketing purposes.

#### R.swift

[R.swift](https://github.com/mac-cain13/R.swift) generates strongly typed references to resources (images, colors, localized strings, storyboards, etc.), reducing runtime errors caused by typos in resource names.

#### Factory

[Factory](https://github.com/hmlongco/Factory) is a lightweight dependency injection framework that helps decouple modules and makes it easier to test and configure dependencies across environments.

#### SwiftLint

[SwiftLint](https://github.com/realm/SwiftLint) is used to enforce our team's Swift style and conventions. It is customizable, lightweight, and integrates with Xcode to report violations during development and on CI.

#### SwiftFormat

[SwiftFormat](https://github.com/nicklockwood/SwiftFormat) is a code formatter for the Swift language. The template uses SwiftFormat as a code convention enforcer. When SwiftFormat runs, the source code is reformatted according to the applied rules. This helps maintain code conventions and reduce the number of warnings.

> When SwiftFormat runs, the code is reformatted, losing the ability to undo and redo. This could cause inconvenience to the development, so the current version of the template runs a `SwiftFormat` command only when starting a `Test` build.

#### Sourcery

Swift code generator running on top of Stencil. [Sourcery](https://github.com/krzysztofzablocki/Sourcery) is used to generate protocol mocks for unit testing purposes. Since the template no longer uses CocoaPods, Sourcery should be integrated via its standalone CLI or build tooling instead of a `Pods` directory.

#### Wormholy

[Wormholy](https://github.com/pmusolino/Wormholy) is a network debugging tool that intercepts and displays HTTP requests made by the app, which is especially useful in debug configurations for inspecting and troubleshooting API calls.

#### xcbeautify

[xcbeautify](https://github.com/cpisciotta/xcbeautify) formats and prettifies `xcodebuild` output, making CI logs and local terminal output easier to read.

#### ArkanaKeys / ArkanaKeysInterfaces

[ArkanaKeys](https://github.com/nimblehq/arkana) manages environment-specific secrets and configuration values. It allows keeping sensitive data out of the repository while still providing a type-safe interface for accessing those values in the app.

## Testing

The template uses **Swift Testing** for unit and integration-style tests and **XCTest / XCUITest** for UI and performance tests. See [[Testing Swift Testing and XCTest]] for conventions and migration guidance.

### SwiftUI

The SwiftUI template relies on the **Common** libraries listed above. UI is implemented using the native `SwiftUI` framework, without additional third‑party SwiftUI-specific libraries by default, keeping the stack minimal and focused on system frameworks.
