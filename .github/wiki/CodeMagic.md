# CodeMagic

Use the CodeMagic template to start a new project with CodeMagic as the CI/CD tool.

## Workflows and Steps

Out of the box, the CodeMagic Template has the following workflows and steps:

| test                      | deploy_app_store                                        | deploy_staging                          | deploy_release_firebase                   |
| ------------------------- | ------------------------------------------------------- | --------------------------------------- | ----------------------------------------- |
| Install bundle            | Install bundle                                          | Install bundle                          | Install bundle                            |
| Run CocoaPods install     | Run CocoaPods install                                   | Run CocoaPods install                   | Run CocoaPods install                     |
| Fastlane - Build and Test | Fastlane - Build and Test                               | Fastlane - Build and Test               | Fastlane - Build and Test                 |
| Fastlane - Clean Up Xcov  | Fastlane Match                                          | Fastlane Match                          | Fastlane Match                            |
| Danger                    | Fastlane - Build and Upload Production App to App Store | Fastlane - Build and Upload Staging App | Fastlane: Build and Upload Production App |

## Trigger Map

| Workflow                | Trigger                 |
| ----------------------- | ----------------------- |
| test                    | Create or Update a PR   |
| deploy_staging          | Push branch `develop`   |
| deploy_release_firebase | Push branch `release/*` |
| deploy_app_store        | Push branch `main`      |

## Environment

### Variables

- MATCH_PASSWORD

> The password is used to encrypt/decrypt the repository to store your distribution certificates and provisioning profiles.

- MATCH_SSH_KEY

> An SSH private key is used for cloning the Match repository that contains your distribution certificates and provisioning.

- KEYCHAIN_PASSWORD

> The password to access the keychain

- FIREBASE_CLI_TOKEN

> Firebase token https://firebase.google.com/docs/cli#cli-ci-systems for uploading build to Firebase Distributions and Analytics.

- APPSTORE_CONNECT_API_KEY

> App Store Connect API https://docs.fastlane.tools/actions/app_store_connect_api_key/ for uploading build to TestFlight or App Store. It should be `base64` encoded.

- API_KEY_ID

> The key identifier of your App Store Connect API key.

- ISSUER_ID

> The issuer of your App Store Connect API key.

- BUMP_APP_STORE_BUILD_NUMBER

> The flag to determine if the Fastlane should bump the app store build number

## Installation

1. Follow the setup instruction in [`README.md`](https://github.com/nimblehq/ios-templates#readme).
2. To connect your repository to CodeMagic, please follow the instruction on this page: [Adding the app to CodeMagic](https://docs.codemagic.io/yaml-quick-start/building-a-native-ios-app).

3. Provide all the required variables and secrets.

> The final project directory structure

```
ROOT
├── ExampleApp.xcworkspace
├── codemagic.yaml
├──...
```

4. Push changes to SCM.