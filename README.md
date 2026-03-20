<p align="center">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://assets.nimblehq.co/logo/dark/logo-dark-text-320.png">
      <img alt="Nimble logo" src="https://assets.nimblehq.co/logo/light/logo-light-text-320.png">
    </picture>
</p>

<p align="center">
  <strong>iOS Templates</strong>
</p>

---

Our optimized iOS template for shipping SwiftUI apps powered by Tuist 4 and Swift Package Manager (SPM).

## Getting Started

### Requirements

- Ruby `3.1.2+`
- Xcode `16.2+`
- Swift `6.1+`
- [mise](https://mise.jdx.dev/) – manages Tuist and xcbeautify versions via `.mise.toml`

### What's inside

- ✅ SwiftUI-only interface – UIKit scaffolding has been removed
- ✅ SPM-only dependencies – CocoaPods and Podfiles are no longer generated
- ✅ Tuist 4.110.3 manifests using the latest `ProjectDescription` helpers
- ✅ Clean modular architecture: Domain + Data layers as SPM frameworks
- ✅ Dependency injection via [Factory](https://github.com/hmlongco/Factory)
- ✅ BDD unit testing with [Quick](https://github.com/Quick/Quick) + [Nimble](https://github.com/Quick/Nimble); UI testing via KIF
- ✅ Code quality tools: SwiftLint, SwiftFormat, Danger, xcov
- ✅ Secret management via [Arkana](https://github.com/rogerluan/arkana)
- ✅ Multi-platform CI/CD (GitHub Actions, Bitrise, CodeMagic) with Fastlane Swift DSL
- ✅ Four build configurations: Debug/Release × Staging/Production

### Use the template

1. Create your repository by pressing the `Use this template` button in this repository or create a new repository and use `nimblehq/ios-templates` as a repository template.
2. Clone your repository.
3. Install tool versions and Ruby dependencies:
    ```bash
    mise install
    bundle install
    ```
4. Generate the project by running the following command in your terminal:
    ```bash
    swift run --package-path scripts/iOSTemplateMaker iOSTemplateMaker make \
      --bundle-id-production com.example.app \
      --bundle-id-staging com.example.app.staging \
      --project-name YourProjectName
    ```
    This will substitute all placeholders, run `tuist generate`, install dependencies, and open the project automatically.
5. Open `<YourProject>.xcodeproj` in Xcode (SPM dependencies appear in **Package Dependencies**).

## Full Documentation

See the [Wiki](https://github.com/nimblehq/ios-templates/wiki/) for full documentation, project details and other information.

## License

This project is Copyright (c) 2014 and onwards. It is free software,
and may be redistributed under the terms specified in the [LICENSE] file.

[LICENSE]: /LICENSE

## About

<picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://assets.nimblehq.co/logo/dark/logo-dark-text-160.png">
      <img alt="Nimble logo" src="https://assets.nimblehq.co/logo/light/logo-light-text-160.png">
</picture>

This project is maintained and funded by Nimble.

We love open source and do our part in sharing our work with the community!
See [our other projects][community] or [hire our team][hire] to help build your product.

[community]: https://github.com/nimblehq
[hire]: https://nimblehq.co/
