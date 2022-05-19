# Github Actions

Use the GitHub Actions template to start a new project with GitHub Actions as the CI/CD tool.

Out of the box, the template contains the following workflows:

## Workflows

There are currently 4 workflows:

- test
- deploy_firebase
- deploy_release_firebase
- deploy_app_store

|Task/Workflow           |test                                                                                                                                |deploy_firebase|deploy_release_firebase|deploy_app_store|
|------------------------|------------------------------------------------------------------------------------------------------------------------------------|---------------|-----------------------|----------------|
|Trigger                 |merge or push to feature/chore/bug branch                                                                                           |merge or push to develop branch|merge or push to release branch|merge or push to main/ master branch|
|Lint (async)            |✅                                                                                                                                   |✅              |✅                      |✅               |
|Test                    |✅                                                                                                                                   |✅              |✅                      |✅               |
|Deploy                  |❌                                                                                                                                   |Staging build to Firebase|Production build to Firebase|Production build to App Store|

## Jobs

### Lint

1. Check out the current version.
2. Run a SwiftLint on a Linux machine. Show result on pull request's check.

### Test

1. Check out the current version.
2. Install dependencies including Gem, Fastlane, and Cocoapods.
3. Run Test on staging scheme and show result on pull request's check.

### Deploy

1. Proceed to 4 if this job is running after `Test` job
2. Check out the current version.
3. Install dependencies including Gem, Fastlane, and Cocoapods.
4. Install provisioning profiles and certificates using Fastlane match.
5. Build archive version of the specified scheme.
6. Deploy to Firebase Distribution, TestFlight, or App Store.

# Installation

## Environment Secrets

Make sure the following secrets are set up.

|Secret                  |Description                                                                                                                         |test|deploy_firebase|deploy_release_firebase|deploy_app_store                   |
|------------------------|------------------------------------------------------------------------------------------------------------------------------------|----|---------------|-----------------------|-----------------------------------|
|SSH_PRIVATE_KEY         |SSH key connected to a user with access to the match repo for check out the match repo.                                             |-   |✅              |✅                      |✅                                  |
|MATCH_PASS              |Fastlane Match Passphrase for decrypting a match repository.                                                                        |-   |✅              |✅                      |✅                                  |
|APPSTORE_CONNECT_API_KEY|App Store Connect API https://docs.fastlane.tools/actions/app_store_connect_api_key/ for uploading build to TestFlight or App Store.|-   |-              |-                      |✅                                  |
|FIREBASE_TOKEN          |Firebase token https://firebase.google.com/docs/cli#cli-ci-systems for uploading build to Firebase Distributions and Analytics.     |-   |✅              |✅                      |✅ For uploading dSYM to Crashlytics|

## Installation

1. Following the setup instruction in `README.md`.
2. Modify the files with project's values:
    - fastlane/Matchfile
    - fastlane/Constants/Constants.rb
3. Provide SECRETS noted in `yml` file in [Github Project's Setting](https://docs.github.com/en/actions/reference/encrypted-secrets)
4. Push changes to Github