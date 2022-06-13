# Bitrise
Use the Bitrise template to start a new project with Bitrise as the CI/CD tool.

## Workflows and Steps

Out of the box, the Bitrise Template has the following workflows and steps:

| test                      | deploy_app_store                                        | deploy_staging                          | deploy_release_firebase                   |
|---------------------------|---------------------------------------------------------|-----------------------------------------|-------------------------------------------|
| Git Clone Repository      | Git Clone Repository                                    | Git Clone Repository                    | Git Clone Repository                      |
| Bitrise.io Cache:Pull     | Bitrise.io Cache:Pull                                   | Bitrise.io Cache:Pull                   | Bitrise.io Cache:Pull                     |
| Run CocoaPods install     | Run CocoaPods install                                   | Run CocoaPods install                   | Run CocoaPods install                     |
| Fastlane - Build and Test | Xcode Test for iOS                                      | Xcode Test for iOS                      | Xcode Test for iOS                        |
| Fastlane - Clean Up Xcov  | Fastlane Match                                          | Fastlane Match                          | Fastlane Match                            |
| Danger                    | Fastlane - Build and Upload Production App to App Store | Fastlane - Build and Upload Staging App | Fastlane: Build and Upload Production App |

## Trigger Map

| Workflow                | Trigger                 |
|-------------------------|-------------------------|
| test                    | Create or Update a PR   |
| deploy_staging          | Push branch `develop`   |
| deploy_release_firebase | Push branch `release/*` |
| deploy_app_store        | Push branch `master`/`main`    |

## Environment and Secrets
### App Environtment Variables
- BITRISE_PROJECT_PATH
> e.g., ExampleApp.xcodeproj or in case you're using CocoaPod, it is ExampleApp.xcworkspace.

- TEAM_ID
> This is your Apple Team ID (e.g., T3T4E84BAA), you can find it in `Membership` at Apple developer portal.

- MATCH_REPO_URL
> Link to a repository that contains your Fastlane Match it can be either HTTPS or SSH link (e.g., https://github.com/nimblehq/fastlane-match.git)

### Workflow Environment Variables
All four workflows have their own variables:

- BUNDLE_ID
> e.g., com.nimblehq.exampleApp

- BITRISE_SCHEME
> Your build scheme in Xcode (e.g., ExampleApp UAT, ExampleApp Staging, or ExampleApp)

*Depending on which workflow, the value of those variables may differ from other workflows.*

### Secrets

- MATCH_PASSWORD
> This is an encryption password for the Match Repo

## Installation
1. Follow the setup instruction in [`README.md`](https://github.com/nimblehq/ios-templates#readme).
2. To connect your repository to Bitrise please follow the instruction in this page: [Adding a new app](https://devcenter.bitrise.io/en/getting-started/adding-your-first-app.html).
3. Make sure the option where the `bitrise.yml` locate is set to `Store in-app repository`.
<p align="center">
  <img src="assets/images/operations/bitrise/Bitrise-YML-Storage-Location.png" alt="Bitrise Store in-app repository" width="600"/>
</p>

4. Provide all the required variables and secrets.
> Final project directory structure
```
ROOT
├── ExampleApp.xcworkspace
├── bitrise.yml
├──...
```
5. Push changes to SCM.
