## Requirements

- Xcode `26+`
- Swift `6.1+`
- Ruby `3.2+`
- [mise](https://mise.jdx.dev/) _(recommended for installing Ruby, Tuist, and xcbeautify from `.mise.toml`)_

## Use the template

1. Create your repository by pressing the `Use this template` button in this repository or create a new repository and use `nimblehq/ios-templates` as a repository template.
2. Clone your repository
3. Install the toolchain:
    ```bash
    mise install
    ```
4. Setup the project by running the following command in your terminal:
    ```bash
    swift run --package-path scripts/iOSTemplateMaker iOSTemplateMaker make
    ```

## Options

Options are optional and will be prompted if not provided. Example is provided in (brackets).

- `--bundle-id-production`: The application's bundle id for production variant. (co.nimblehq.project)
- `--bundle-id-staging`: The application's bundle id for staging variant. (co.nimblehq.project.staging)
- `--bundle-id-dev`: The application's bundle id for dev variant. (co.nimblehq.project.dev)
- `--project-name`: The name of the project. (Project)
- `--minimum-version`: The minimum version of the iOS application. (16.0)
- `--cicd`: The CI/CD service to configure. (github, bitrise, codemagic, none)
- `--github-runner`: The GitHub Actions runner type. Only used when `--cicd=github`. (macos-latest, self-hosted)
- `--setup-constants`: Flag to open `Constant.swift` for delivery constants setup after project generation.

### Example

```bash
swift run --package-path scripts/iOSTemplateMaker iOSTemplateMaker make --bundle-id-production co.nimblehq.ios.templates --bundle-id-staging co.nimblehq.ios.templates.staging --bundle-id-dev co.nimblehq.ios.templates.dev --project-name TemplateApp
```
