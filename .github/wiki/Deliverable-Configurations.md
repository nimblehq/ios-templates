## Deliverable Configurations

Build delivery is currently configured in two places:

- `fastlane/Constants/Constant.swift` for Firebase lanes and shared release constants
- `.asc/export-options-app-store.plist` for the App Store export configuration used by `asc`

## Use the template

1. Running the `iOSTemplateMaker` script will ask if the developer wants to set up delivery constants.
2. When confirming with the prompt, the template will launch Xcode with both configuration files open.

## Configure later

- Developer can modify the delivery settings at any time.
- Open `fastlane/Constants/Constant.swift` for Fastlane-managed values.
- Open `.asc/export-options-app-store.plist` for the `asc` App Store export settings.
