## Requirements

- Xcode `13.3+`
- Ruby `3.1.2`

## Use the template

1. Create your repository by pressing the `Use this template` button in this repository or create a new repository and use `nimblehq/ios-templates` as a repository template.
2. Clone your repository
3. Setup the project by running the following command in your terminal:
    ```bash
    swift run --package-path Scripts/Swift/iOSTemplateMaker iOSTemplateMaker make
    ```

## Options

Options are optional and will be prompted if not provided. Example is provided in (brackets).

- `--bundle-id-production`: The application's bundle id for production variant. (co.nimblehq.project)
- `--bundle-id-staging`: The application's bundle id for staging variant. (co.nimblehq.project.staging)
- `--project-name`: The name of the project. (Project)
- `--minimum-version`: The minimum version of the iOS application. (14.0)
- `--interface`: The user interface. (UIKit or SwiftUI)

### Example

```
swift run --package-path Scripts/Swift/iOSTemplateMaker iOSTemplateMaker make --bundle-id-production co.nimblehq.ios.templates --bundle-id-staging co.nimblehq.ios.templates.staging --project-name TemplateApp --interface SwiftUI
```
