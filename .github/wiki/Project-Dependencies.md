To simplify setup for developers new to the application, as well as having a reliable build system that is also able to run in a reproducible fashion. The creation and set up of a new project will be faster and safer. It will require only the language runtime (`Ruby`) and dependency manager installed as prerequisites.

The project normally contains:

- Fastlane: is the easiest way to automate beta deployments and releases for the `iOS` (also `Android`) applications. 🚀 It handles all tedious tasks, such as generating screenshots, dealing with code signing, and releasing the application.
- Cocoapods: manages dependencies for Xcode projects. Cocoapods aims to improve the engagement with, and discoverability of, third-party open-source Cocoa libraries. Developers only need to specify the dependencies in a file named `Podfile`. Cocoapods recursively resolves dependencies between libraries, fetches source code for all dependencies, and creates and maintains an Xcode workspace to build the project.
- Swift Package Manager: a tool for managing the distribution of Swift code. It’s integrated with the Swift build system to automate the process of downloading, compiling, and linking dependencies.

## Dependencies

### Bundler

[Bundler](https://bundler.io/) is a Ruby package manager, think of it as a Cocoapods for ruby plugins that will be used for the project. Keeping package versions the same on all development machines and Continuous Development machines reduces unnoticed bugs from occurring. Noteworthy packages include `Fastlane`, `Firebase-cli`, and `Cocoapods`.

### Cocoapods

[Cocoapods](https://cocoapods.org/) manages iOS packages to keep consistency throughout development machines.

### Fastlane

[Fastlane](https://fastlane.tools/) automates test, build, and most importantly: certificates and profiles which are a core part of the App Store ecosystem.

### Firebase

The main usage of [Firebase](https://firebase.google.com/) for our team is `Firebase Crashlytics` and `Firebase Distribution`. `Firebase Crashlytics` is used to track, prioritize, and fix stability issues that erode the app quality. `Firebase Distribution` is the primary method for QA and Client to download applications for testing and presenting purposes. In some projects, `Firebase Analytics` is being used to track and analyze users' behavior for marketing purposes.

## Libraries

### Alamofire

[Alamofire](https://github.com/Alamofire/Alamofire) is a networking library for Swift projects. Alamofire is used as a base for our Networking layer to streamline API calls in all projects, allowing developers to switch between projects without an issue.

### SnapKit (pre-SwiftUI)

[SnapKit](https://github.com/SnapKit/SnapKit) is the tool for layout user interface with ease and easier to establish a team's convention. SnapKit applies Auto Layout using a more concise syntax. This allows the UI to be responsive on different devices.

### RxSwift

[RxSwift](https://github.com/ReactiveX/RxSwift) is the library for writing Swift in the reactive programming way. RxSwift added a reactive framework for Swift with syntax closely resembling other Rx frameworks. Although it is possible to implement reactive programming for Swift, RxSwift can bypass problems that arise from maintaining large plugins and allow developers from other platforms to easily understand RxSwift syntax.

### IQKeyboardManagerSwift

[IQKeyboardManager](https://github.com/hackiftekhar/IQKeyboardManager) is a plugin for `UIScrollView`. IQKeyboardManager will detect when the keyboard is showing and adjust the view so that the view is not blocked by the keyboard. IQKeyboardManager is the go-to solution because of the ease of installation and history of maintenance by the developers.

### SwiftLint

[SwiftLin](https://github.com/realm/SwiftLint) is used to enforce our team's code convention. SwiftLint is the perfect tool for this task as it is customizable, lightweight, and automate-able. Our team installs SwiftLint with `Ruby` to allow Continuous Integration machine capability to replicate local lint. SwiftLint is integrated with Xcode to display a warning and halt build when error.

### KeychainAccess

[KeychainAccess](https://github.com/kishikawakatsumi/KeychainAccess) is a wrapper for Keychain, making storing data with Apple's encryption as convenient as using `UserDefault`.

### Sourcery

Swift code generator running on top of Stencil. [Sourcery](https://github.com/krzysztofzablocki/Sourcery) is used to generate Protocol's Mock for Unit Testing purposes. We include Sourcery in `podfile` and add a shell script to Xcode Build Phrase `./Pods/Sourcery/bin/sourcery`.

### SwiftFormat

[SwiftFormat](https://github.com/nicklockwood/SwiftFormat) is a code formatter for Swift language. The template uses SwiftFormat as a code convention enforcer. When SwiftFormat runs, the source code is reformatted according to the applied rules. This helps with keeping code conventions and reducing the number of warnings.

> When the `SwiftFormat` runs, the code is reformatted, making them lose the ability to undo and redo. This could cause inconvenience to the development, so the current version of the template runs a `SwiftFormat` command only when starting a `Test` build.

