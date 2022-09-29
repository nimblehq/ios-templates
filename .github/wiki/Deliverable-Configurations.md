## Deliverable Configurations

The file [DeliverableConstants.rb](https://github.com/nimblehq/ios-templates/blob/develop/fastlane/Constants/DeliverableConstants.rb) contains the settings for build delivery, including:
- Firebase
- App Store

## Use the template

1. Running the `make.sh` script will ask if the developer wants to configure the `DeliverableConstants` file.
2. When confirming with the prompt, the template will launch Xcode to modify the `DeliverableConstants` file.

## Configure later

- Developer can modify the `DeliverableConstants` at any time.
- Use the command `sh deliverable_setup.sh` to open `DeliverableConstants` with Xcode.
- Open the file manually at `fastlane/Constants/DeliverableConstants.rb` with any IDE.
