## Project Structure

To keep all current and upcoming iOS projects aligned, we standardize an iOS project's file organization by following this below structure:

```
.
├── README.md
├── Modules/
│   ├── Data/
│   │   ├── Sources/
│   │   │   ├── NetworkAPI/
│   │   │   │   ├── Core/
│   │   │   │   │   ├── NetworkAPIError.swift
│   │   │   │   │   ├── NetworkAPIProtocol.swift
│   │   │   │   │   └── RequestConfiguration.swift
│   │   │   │   ├── Interceptors
│   │   │   │   ├── Models
│   │   │   │   ├── RequestConfigurations
│   │   │   │   └── NetworkAPI.swift
│   │   │   └── Repositories
│   │   └── Tests/
│   │       ├── Resources
│   │       └── Sources/
│   │           ├── Dummies/
│   │           │   ├── DummyNetworkModel.swift
│   │           │   └── DummyRequestConfiguration.swift
│   │           ├── Specs/
│   │           │   └── NetworkAPI
│   │           └── Utilities/
│   │               └── NetworkStubber.swift
│   └── Domain/
│       ├── Sources/
│       │   ├── Entities
│       │   ├── Interfaces
│       │   └── UseCases/
│       │       └── UseCaseFactoryProtocol.swift
│       └── Tests/
│           ├── Resources
│           └── Sources/
│               └── Specs/
│                   └── DomainSwiftTestingTests.swift
├── {ProjectName}/
│   ├── Configurations/
│   │   ├── Plists/
│   │   │   └── GoogleService/
│   │   │       ├── Production
│   │   │       └── Staging
│   │   └── XCConfigs
│   ├── Resources/
│   │   ├── Assets
│   │   └── LaunchScreen
│   └── Sources/
│       ├── Application/
│       │   └── {ProjectName}App.swift
│       ├── Constants/
│       │   ├── Constants+API.swift
│       │   └── Constants.swift
│       ├── Presentation/
│       │   ├── Coordinators
│       │   ├── Models
│       │   ├── Modules
│       │   ├── Styles
│       │   ├── ViewIds
│       │   ├── ViewModifiers
│       │   └── Views
│       └── Supports/
│           └── Extensions/
│               └── Foundation
├── {ProjectName}Tests/
│   ├── Configurations/
│   │   └── Plists
│   ├── Resources
│   └── Sources/
│       └── Specs/
│           └── Supports/
│               └── Extensions/
│                   └── Foundation
└── {ProjectName}UITests/
    ├── Configurations/
    │   └── Plists
    └── Sources/
        └── Specs/
            └── Application
```

## README.md

`README.md` introduces the overview of the project, for example:

- What is the main feature of the project?
- How to set up the project?
- What are project configurations?

## Modules

This folder contains modules which represent targets in the project. Currently, it contains `Data` and `Domain` folder.

- Data: This folder contains two subfolders
  - Sources: This folder contains only `.swift` files - the main source code of the module.
  - Tests: This folder contains the unit testing.
- Domain: This folder contains source files and Unit Test for the `Domain` target.
  - Sources: This folder contains only `.swift` files - the main source code of the module.
  - Tests: This folder contains the unit testing.

## {ProjectName}

This folder contains the main sources of the project. There are three sub-folders:

- Configurations: This folder contains only project configurations files, such as `Info.plist`, `.xconfig`, `.entitlements`, etc.
- Resources: This folder contains only `resources` files, such as `.plist`, `.json`, `.tff` (fonts), `.strings`, `.der` (SSL certificates), etc.
- Sources: This folder contains only `.swift` files - the main source code of the project.

## {ProjectName}Tests

This folder contains the unit testing and integration testing of the main project.

## {ProjectName}UITests

This folder contains UI and performance tests using XCTest / XCUITest.
