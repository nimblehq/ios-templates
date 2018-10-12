# ios-template
Our optimized iOS template used in our projects

## Usage

```
brew install flintbox/Flint/flint
flint t c https://github.com/nimbl3/ios-templates
flint s ios-templates
```

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

  - Schemes:
    - This project is set up with 6 schemes as listed below:
      - **{Project name}** - targeted at production level for releasing to App Store.
      - **{Project name} staging** - set up for staging environment with Ad-hoc distribution provisioning profile for releasing beta to Crashlytics.
      - **{Project name} debug** - set up for staging environment with development
      provisioning profile for development and debugging. This scheme includes unit testing.
      - **{Project name} test suite** - configured for both UI and unit tests. *This scheme is intended for Jenkins to build testing targets only once.*
      - **{Project name} unit-tests** - configured for unit tests only.
      - **{Project name} ui-tests** - configured for UI tests only.

> When working on the project, usually **test suite** and **unit-tests** can be omitted as the former one is only meant for building testing targets, and unit tests are already includes in **debug** scheme for the latter one.

  - Add a run script for SwiftLint
  - Add a run script for Crashlytics
  - Integrate UI and unit test

#### Code Signing
  - AppID
    - AppIDs can be created automatically with `lane :create_app_ids`, this will create AppIDs for `Appstore`, `Staging` and `Debug` schemes.
  - App Store Connect 
    - App in App Store Connect needs to be created manually. 
  - Certificate
    - Development
      - for DEBUG build configuration.
    - Distribution
      - for STAGING and RELEASE build configuration.
  - Mobile Provision
    - Development
      - for DEBUG build configuration, build directly to iOS Devices.
    - Adhoc
      - for STAGING build configuration, deploy to Crashlytics.
      - Beta devices on Crashlytics need to be added to Apple Developer Portal and build with Mobile Provision that include Beta Devices.
    - Appstore
      - for RELEASE build configuration, release to AppStore.

#### Cocoapods integration
  - Podfile including:
    - Alamofire
    - SwiftLint
    - Fabric
    - Crashlytics
    - Quick _- Test target only_
    - Nimble _- Test target only_

#### Fabric & Crashlytics Integration
  - Application Bundle Identifier need to be added to `Fabric.app` first.
  - Follow the `Fabric.app` instructions, **ignore** import Fabric & Crashlytics to Xcode Project and `AppDelegate.swift` process.
  - When `Fabric.app` ask to build or run, execute it with `STAGING` scheme.
  - `Fabric` tester group can be configured in `./fastlane/.env`
  - `Fabric` tester group will be able to create on `Fabric` website after first product is deployed.  

#### SwiftLint integration
More information on opted in/out Rules to come...

#### Bundler
 - Bundle Including: 
   - Fastlane (2.88.0)
   - CocoaPods (1.4.0)
  
#### Fastlane integration
 - Files
    - [Appfile](https://docs.fastlane.tools/advanced/#appfile)
      -  stores the app identifier and your Apple ID.
    - [Fastfile](https://docs.fastlane.tools/advanced/#fastfile)
      -  manages the lanes you create to call certain actions.
    - [Gymfile](https://docs.fastlane.tools/actions/gym/#gymfile)
      - stores default building configuration. 
    - .env 
      - store project information for fastlane to execute lanes.
      - Slack WebHook is optional. 
  - Lanes
    - `private_lane :create_app_on_developer_portal`
      - create `App ID` for all app bundles.
    - `lane :download_certs_and_provisioning_profiles`
      - create new or download `certificate` and `mobileProvision` for all app bundles.
    - `lane :create_app_id_and_code_signing`
      - create `App ID` on developer portal then `download_certs_and_provisioning_profiles`
    - `clear_all`
      - delete `deriveData` and `build` directories in project. 

#### Credentials Management 
 There're some environment variables required to be set up both on Local machine and Jenkins Master
  - **${PREFIX}**_CRASHLYTICS_API_TOKEN
  - **${PREFIX}**_CRASHLYTICS_BUILD_SECRET
  - **${PREFIX}**_MATCH_PASSWORD
  - **${PREFIX}**_PT_PROJECT_ID
  - **${PREFIX}**_PT_PROJECT_TOKEN
  - **${PREFIX}**_BITBUCKET_CREDENTIAL
  > **${PREFIX}** is project name uppercased.  

- Local machine
  - These variables need to be defined and export in `.zshrc` at the root directory of current user's machine.
- Jenkins master 
  - These variables need to be set on Jenkins with this following navigation. 
    - `Project > Credentials > Project's Scope > Add credentials`
  - All credentials can be passed as environment variables in Jenkinsfile using [Jenkins Credentials Binding](https://jenkins.io/doc/pipeline/steps/credentials-binding/)
#### **Jenkins**

Using `[skip-ci]` in commit message will make Jenkins skip every pipeline on the job.

Using `[skip-deploy]` in commit message or pull request title will make Jenkins skip `Build for deploy` and `Deploy` steps. 

**[Nimbl3's Jenkins](http://jenkins.nimbl3.com)** is configured with global shared library linking to `master` branch of [jenkins-shared-library](https://github.com/nimbl3/jenkins-pipeline-shared) repository.

> Be cautious of the usage of `[skip-ci]` as, currently, it will make the job's result to `SUCCESS` all the time.