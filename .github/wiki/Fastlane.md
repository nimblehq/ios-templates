Fastlane is a part of the automation tool for the development and release process of the project. By converting to Fastlane.swift, we can now write our configuration using Xcode in Swift - the language we know and love from the world of iOS development. This document will mention some crucial parts of the pipeline.

<img src="assets/images/infrastructure/fastlane/fastlane.png" width=300>

## Fastfile

### Build and test

The lane `buildAndTest` helps build and test the application with the configuration of the test scheme and test target defined in the `Constant.swift` file.

Example:

```
$ bundle exec fastlane buildAndTest
```

After running this lane successfully, it will generate the code coverage report.

> See more:
> 
> - [Constant.swift](#constantswift)

### Synchronize the provisioning profile

As the developer team has many developers, it is recommended to synchronize the certificates and profiles across the team during the development process.

The `fastlane match` is here for sharing one code signing identity across the development team to simplify the codesigning setup and prevent code signing issues.

To synchronize the machine with the certificates and profiles, which are stored in a match repository, please use the following lanes:

| `syncDevelopmentCodeSigning` | `syncAdHocStagingCodeSigning` | `syncAdHocProductionCodeSigning` | `syncAppStoreCodeSigning` |
|---|---|---|---|
| Synchronize the Development match signing for the Staging build. | Synchronize the Ad Hoc match signing for the Staging build. | Synchronize the Ad Hoc match signing for the Production build. | Synchronize the App Store match signing for the Production build. |


Example:

```
$ bundle exec fastlane syncDevelopmentCodeSigning
$ bundle exec fastlane syncAdHocStagingCodeSigning
$ bundle exec fastlane syncAdHocProductionCodeSigning
$ bundle exec fastlane syncAppStoreCodeSigning
```

### Register a new device

To register a new device and synchronize the new device across the development team, use the lane `registerNewDevice` and provide the device UDID along with the device name:

Example:

```
$ bundle exec fastlane registerNewDevice
```

### Build and upload the application

To build and upload the application to distribution platforms, like Firebase or App Store Connect, please use these lanes:

| `buildStagingAndUploadToFirebase` | `buildProductionAndUploadToFirebase` | `buildAndUploadToAppStore` | `buildAndUploadToTestFlight` |
|---|---|---|---|
| To upload the Staging build and Staging dSYM file to Firebase. | To upload the Production build and Production dSYM file to Firebase. | To upload the Production build to App Store. | To upload the Production build to TestFlight. |

Example: 

```
$ bundle exec fastlane buildStagingAndUploadToFirebase
$ bundle exec fastlane buildProductionAndUploadToFirebase
$ bundle exec fastlane buildAndUploadToAppStore
$ bundle exec fastlane buildAndUploadToTestFlight
```

> See more:
> 
> - [Build.swift](#buildswift)
> - [Distribution.swift](#distributionswift)


## Matchfile

Define the essential information to synchronize the certificates and profiles across the development team.

> See more:
> 
> - [Match.swift](#matchswift)
> - [Synchronize the provisioning profile](#synchronize-the-provisioning-profile)

## Constants folder

### Constant.swift

Contains the key/value pairs of constants used during the development and release process.

### Secret.swift

Contains the key/value pairs of environment variables used during the development and release process.

## Managers folder

### Build.swift

`Build.swift` helps build and sign the application. There are two main functions:

| `adHoc` | `appStore` |
|---|---|
| Build and sign the application with the `adHoc` distribution and the environment parameter (`staging` or `production`) | Build and sign the application with the `appStore` distribution. |

> See more:
>
> - [Build and upload the application](#build-and-upload-the-application)

### Distribution.swift

`Distribution.swift` is in charge of distributing the build to the distribution platforms, such as Firebase, App Store Connect, and Testflight.

> See more:
>
> - [Build and upload the application](#build-and-upload-the-application)

### Match.swift

The responsibility of `Match` is to synchronize the teams' certificates and profiles during the development process.

> See more:
>
> - [Synchronize the provisioning profile](#synchronize-the-provisioning-profile)
> - [Matchfile](#matchfile)

### Symbol.swift

Technically, the debug Symbol file (dSYM file) is used to de-obfuscate stack traces from crashes on the production app. The dSYM files store the debug symbols for the application. Then services (like Crashlytics) use the dSYM files to replace the symbols in the crash reports with the originating locations in the source code. Hence, the crash reports will be more readable and understandable.

The `Symbol` helps process and upload dSYM file to Firebase. There is only one primary function:

| `uploadToCrashlytics` |
|---|
| Directly upload the built dSYM file to Crashlytics with the environment parameter (`staging` or `production`). |
| It is recommended to use this function when the build configuration is `Release Staging` or `Release Production`. |
| See more: [Debug Symbol File](Project-Configurations.md#debug-symbol-file) |

### Test.swift

The `Test` helps build and test the application.

### Version.swift

The `Version` manages the application's build number and version number.