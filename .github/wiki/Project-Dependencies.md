To simplify setup for developers new to the application and to ensure a system that runs reproducibly reliable builds. The creation and setup of a new project will be faster and safer. It will require only the language runtime (`Ruby`) and the dependency manager installed as prerequisites.

The project normally contains:

- Fastlane is the easiest way to automate beta deployments and releases for `iOS` (also `Android`) applications. 🚀 It handles all tedious tasks, such as generating screenshots, dealing with code signing, and releasing the application.
- Cocoapods: manages dependencies for Xcode projects. Cocoapods aims to improve engagement with and discoverability of third-party open-source Cocoa libraries. Developers only need to specify the dependencies in a file named `Podfile`. Cocoapods recursively resolves dependencies between libraries, fetches source code for all dependencies, and creates and maintains an Xcode workspace to build the project.
- Swift Package Manager: a tool for managing the distribution of Swift code. It’s integrated with the Swift build system to automate the process of downloading, compiling, and linking dependencies.

## Dependencies

### Bundler

[Bundler](https://bundler.io/) is a Ruby package manager, think of it as a Cocoapods for Ruby plugins that will be used for the project. Keeping package versions the same across all development and Continuous Development machines reduces the risk of unnoticed bugs. Noteworthy packages include `Fastlane`, `Firebase CLI, and CocoaPods`.

### Cocoapods

[Cocoapods](https://cocoapods.org/) manages iOS packages to keep consistency throughout development machines.

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

#### KeychainAccess

[KeychainAccess](https://github.com/kishikawakatsumi/KeychainAccess) is a wrapper for Keychain, making storing data with Apple's encryption as convenient as using `UserDefault`.

#### Firebase (Crashlytics & Distribution)

The main usage of [Firebase](https://firebase.google.com/) for our team is `Firebase Crashlytics` and `Firebase Distribution`. `Firebase Crashlytics` is used to track, prioritize, and fix stability issues that erode the app quality. `Firebase Distribution` is the primary method for QA and Client to download applications for testing and presenting purposes. In some projects, `Firebase Analytics` is being used to track and analyze users' behavior for marketing purposes.

#### NimbleExtension

[NimbleExtension](https://github.com/nimblehq/NimbleExtension) provides a collection of utility extensions commonly used across Nimble projects to reduce boilerplate and keep codebases consistent.

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

Swift code generator running on top of Stencil. [Sourcery](https://github.com/krzysztofzablocki/Sourcery) is used to generate Protocol's Mock for Unit Testing purposes. We include Sourcery in the `podfile` and add a shell script to Xcode Build Phase `./Pods/Sourcery/bin/sourcery`.

#### Wormholy

[Wormholy](https://github.com/pmusolino/Wormholy) is a network debugging tool that intercepts and displays HTTP requests made by the app, which is especially useful in debug configurations for inspecting and troubleshooting API calls.

#### xcbeautify

[xcbeautify](https://github.com/cpisciotta/xcbeautify) formats and prettifies `xcodebuild` output, making CI logs and local terminal output easier to read.

#### ArkanaKeys / ArkanaKeysInterfaces

[ArkanaKeys](https://github.com/nimblehq/arkana) manages environment-specific secrets and configuration values. It allows keeping sensitive data out of the repository while still providing a type-safe interface for accessing those values in the app.

### SwiftUI

The SwiftUI template relies on the **Common** libraries listed above. UI is implemented using the native `SwiftUI` framework, without additional third‑party SwiftUI-specific libraries by default, keeping the stack minimal and focused on system frameworks.

### UIKit

#### SnapKit

[SnapKit](https://github.com/SnapKit/SnapKit) is the tool for laying out user interfaces with ease, and it makes it easier to establish a team's conventions. SnapKit applies Auto Layout using a more concise syntax. This allows the UI to be responsive on different devices.

#### IQKeyboardManagerSwift

[IQKeyboardManager](https://github.com/hackiftekhar/IQKeyboardManager) is a plugin for `UIScrollView`. IQKeyboardManager will detect when the keyboard is showing and adjust the view so it is not blocked. IQKeyboardManager is the go-to solution due to its ease of installation and the developers' history of maintenance.

