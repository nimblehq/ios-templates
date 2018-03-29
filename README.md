# ios-template
Our optimized iOS template used in our projects

## Usage
Run `Bakery` file to generate project from template. Simply follow the steps.

## What's included

Below are what's included in the template project.

#### Basic project configuration
  - Standard file organization:
```
ROOT
├─ Application
  ├─ Constants
  ├─ Infos
    ├─ Info.plist
  ├─ Resources
    ├─ Assets.xcassets
  ├─ AppDelegate.swift
  ├─ LaunchScreen.storyboard
├─ Controllers
├─ Extensions
├─ Models
├─ Protocols
├─ Services
├─ Views
```
  - Build configurations:
    - **Debug** for development - _with `DEBUG` flag defined_
    - **Release** for releasing to App Store - _with `RELEASE` flag defined_
    - **Staging** for releasing beta - _with `STAGING` flag defined_
  - Schemes setup:
    - **_{Project name}_** - with _release_ configuration without tests
    - **_{Project name}_ debug** - with _debug_ configuration and tests included
    - **_{Project name}_ staging** - with _staging_ configuration and tests included
  - Set _Defines module_ to `YES` for enabling Quick & Nimble test module.
  - Add a run script for SwiftLint
  - Add a run script for Crashlytics
  - Integrate UI and unit test

#### Cocoapods integration
  - Podfile including:
    - Alamofire
    - SwiftLint
    - Fabric
    - Crashlytics
    - Quick _- Test target only_
    - Nimble _- Test target only_

#### SwiftLint integration
More information on opted in/out Rules to come...

#### Fastlane integration
More information to come...
