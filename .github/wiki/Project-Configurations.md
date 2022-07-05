This document presents in detail the set of configurations used in the iOS projects developed at Nimble. Included in this document are:

- Terminologies and topics related to project configurations.
- Basic targets, schemes, build settings options, etc., for building a project.

## Project Terminology

### Targets

A target specifies a product to build, such as an iOS, watchOS, or macOS app.

When creating a project from a template, a default target will be added automatically for the main application.

There are 3 default targets in a project:

- {ProjectName}
- {ProjectName}Tests
- {ProjectName}UITests

### Schemes

A scheme is a collection of settings that specifies the targets to build for a project, the build configuration to use, and the executable environment to use when the product is launched.

The 2 main schemes in a project:

- {ProjectName}
- {ProjectName} Staging

### Build Configurations in Schemes

It is possible to build a scheme with different Build Configurations. Initially, there are 2 basic configurations for a project generated automatically by Xcode, which are:

- Debug
- Release

However, these basic configurations are not enough for our development process. Since our team always wants to ensure the application is working in a designated manner, additional levels of testing are required before the application is ready to be used.

The recommended set of configurations to have is:

- Debug Staging
- Release Staging
- Debug Production
- Release Production

## Predefined Build Options

### Active Compilation Conditions

Having distinct flags for each configuration is the preferred solution.

Xcode provides a build setting named `Active Compilation Conditions`, which supports passing conditional compilation flags to the Swift compiler.

In our iOS template project, there are three custom conditional compilation flags: `DEBUG`, `STAGING`, `PRODUCTION`. The following table will describe how the developers differentiate a configuration from the others.

| Build Configurations | DEBUG | STAGING | PRODUCTION |
|---|---|---|---|
| Debug Staging | ✔︎ | ✔︎ |  |
| Release Staging |  | ✔︎ |  |
| Debug Production | ✔︎ |  | ✔︎ |
| Release Production |  |  | ✔︎ |

The major advantage of custom flags is to allow customizable specific features based on a particular environment.

Example: 

Specify a value based on the environment:

```swift
enum Environment {

    static func based<T>(staging: T, production: T) -> T {
        #if PRODUCTION
        return production
        #else
        return staging
        #endif
	}
}
```

During the development process, all functionalities and frameworks are available in the application. However, there can be situations when the developers just want to turn on some features for a particular environment without creating separate modules for the application. In these cases, declaring a condition to include or exclude code using `Active Compilation Conditions` is the recommended solution.

```swift
#if DEBUG
    // Code the app includes in DEBUG environments
#else
    // Code the app includes when it is not build with DEBUG environments
#endif
```

### Xcode Configuration File

A Configuration Settings File (`*.xcconfig`), also known as a build configuration file, is a plain text file that defines and overrides the default build settings for a particular build configuration of a project or target. This type of file can be edited outside of Xcode and integrates well with source control systems.

Because of different settings for each environment (such as bundle identifiers, endpoints, etc.), the developers also define them in different *.xcconfig files.

### Settings Bundle

To support multiple levels of testing, the `Settings Bundle` is usually integrated along with the dev configurations (a **.plist** file). In addition, the Settings Bundle facilitates the testing process. It creates a shortcut to change environment values without using any third-party API or server.

Settings Bundle works well when developing:

- [Feature toggle](https://martinfowler.com/articles/feature-toggles.html)
- [A/B Testing](https://en.wikipedia.org/wiki/A/B_testing)
- Change API endpoints for testing the application with multiple servers
- Define a list of prefilled credentials and a toggle for prefilling

The Settings Bundle is only enabled on Dev environments. It is optional for Beta environments.

### Debug Symbol File

Basically, the debug Symbol file (`dSYM` file) is used to de-obfuscate stack traces from crashes happening on the production app. The dSYM files store the debug symbols for the application. Then services (like Crashlytics) use the dSYM files to replace the symbols in the crash reports with the originating locations in the source code. Hence, the crash reports will be more readable and understandable.

Go to **Build Settings** → **Debug Information Format**. The debug symbols with a dSYM file (DWARF with dSYM file) are enabled for the release build by default.

A benefit of using the dSYM is reducing the binary size when building an application. Read more about it in the technical note [TN2151](https://developer.apple.com/library/archive/technotes/tn2151/_index.html).

Only include the dSYM file for release builds.

| Build Configurations | Included dSYM file |
|---|---|
| Debug Staging |  |
| Release Staging | ✔︎ |
| Debug Production |  |
| Release Production | ✔︎ |

### Enable Bitcode

Bitcode is a technology that enables recompiling applications to reduce their size. The recompilation happens when the application is uploaded to the App Store Connect or exported for Ad Hoc, Development, or Enterprise distribution.

Enable build with bitcode for Production only.

| Build configurations | Enable Bitcode |
|---|---|
| Debug Staging |  |
| Release Staging |  |
| Debug Production |  |
| Release Production | ✔︎ |
