## Selecting User Interface

Current the template supports setup with two user interfaces:
- UIKit
- SwiftUI

To select a user interface when creating a project pass the argument `--interface [SwiftUI or UIKit]` with the `make` script. 

    ```bash
    sh make.sh --bundle-id [BUNDLE_ID_PRODUCTION] --bundle-id-staging [BUNDLE_ID_STAGING] --project-name [PROJECT_NAME] --interface SwiftUI
    ```
