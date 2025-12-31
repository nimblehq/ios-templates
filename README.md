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

- Ruby `3.1.2`
- Xcode `15+`
- Tuist (version managed via `.mise.toml` - install with `mise install`)

### What's inside

- ✅ SwiftUI-only interface – UIKit scaffolding has been removed
- ✅ SPM-only dependencies – CocoaPods and Podfiles are no longer generated
- ✅ Tuist 4.110.3 manifests using the latest `ProjectDescription` helpers
- ✅ CI-ready scripts (GitHub Actions / Fastlane) aligned with the new setup

### Use the template

1. Create your repository by pressing the `Use this template` button in this repository or create a new repository and use `nimblehq/ios-templates` as a repository template.
2. Clone your repository
3. Setup the project by running the following command in your terminal:
    ```bash
    swift run --package-path Scripts/Swift/iOSTemplateMaker iOSTemplateMaker make
    ```
4. Open the generated `<YourProject>.xcodeproj` (SPM dependencies appear in **Package Dependencies**)

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
