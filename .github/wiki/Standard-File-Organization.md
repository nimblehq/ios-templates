## Project Structure

To keep all current and upcoming iOS projects aligned, we standardize an iOS project’s file organization by following this below structure:

### Common

```
.
├── README.md
├── Modules/
│   ├── Data/
│   │   ├── Sources/
│   │   │   ├── NetworkAPI/
│   │   │   │   ├── Interceptors
│   │   │   │   ├── Models
│   │   │   │   ├── RequestConfigurations
│   │   │   │   ├── Core/
│   │   │   │   │   ├── NetworkAPIError.swift
│   │   │   │   │   ├── NetworkAPIProtocol.swift
│   │   │   │   │   └── RequestConfiguration.swift
│   │   │   │   └── NetworkAPI.swift
│   │   │   └── Repositories
│   │   └── Tests/
│   │       ├── Resources
│   │       └── Sources/
│   │           ├── Dummies/
│   │           │   ├── DummyNetworkModel.swift
│   │           │   └── DummyRequestConfiguration.swift
│   │           ├── Specs/
│   │           │   └── NetworkAPISpec.swift
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
│               └── DummySpec.swift
├── {ProjectName}/
│   ├── Configurations/
│   │   ├── Plists
│   │   └── XCConfigs
│   ├── Resources/
│   │   ├── Assets
│   │   ├── Languages
│   │   └── LaunchScreen
│   └── Sources/
│       ├── Application/
│       │   └── Varies by UI Interface
│       ├── Constants/
│       │   ├── Constants+API.swift
│       │   └── Constants.swift
│       ├── Presentations/
│       │   └── Varies by UI Interaface
│       └── Supports/
│           ├── Builder/
│           │   └── Builder.swift
│           ├── Extensions/
│           │   ├── Foundation
│           │   └── UIKit
│           └── Helpers/
│               ├── Typealias
│               └── UIKit
├── {ProjectName}Tests/
│   ├── Configurations/
│   │   └── Plists
│   ├── Resources
│   └── Sources/
│       ├── Dummy/
│       │   ├── Data/
│       │   │   └── Models
│       │   ├── Domain/
│       │   │   └── Entities
│       │   └── Modules/
│       │       └── Home
│       ├── Mocks/
│       │   ├── NetworkAPIMock.swift
│       │   └── Sourcery/
│       │       ├── AutoMockable.generated.swift
│       │       └── HomeViewModelProtocolMock+Equatable.swift
│       ├── Specs/
│       │   ├── Presentation/
│       │   │   ├── Modules
│       │   │   └── Navigator
│       │   └── Supports/
│       │       └── Extensions
│       └── Utilities/
│           ├── Data+Decode.swift
│           ├── String+Data.swift
│           └── TestError.swift
└── {ProjectName}KIFUITests/
    ├── Configurations/
    │   └── Plists
    └── Sources/
        ├── AccessibilityIdentifiers/
        │   ├── Login
        │   └── Home
        ├── Flows/
        │   ├── Login
        │   └── Home
        ├── Screens/
        │   ├── Login
        │   └── Home
        ├── Specs/
        │   ├── Login
        │   └── Home
        └── Utilities/
            └── KIF+Swift.swift
```

### SwiftUI

```
.
└── {ProjectName}
    └── Sources
        ├── Application
        │   ├── {ProjectName}App.swift
        │   └── AppDelegate.swift
        └── Presentation
            ├── Models
            │   └── ProductUIModel.swift
            ├── Coordinators
            │   └── AppCoordinator.swift
            ├── Modules
            │   ├── Home
            │   └── Login
            ├── Styles
            │   └── RoundedButtonStyle.swift
            ├── ViewModifiers
            │   └── View+PrimaryNavigationBar.swift
            ├── Views
            │   └── SearchBarView.swift
            └── ViewIds
                └── ViewId.swift
```

### UIKit

```
.
└── {ProjectName}
    └── Sources
        ├── Application
        │   ├── AppDelegate.swift
        │   ├── Application.swift
        │   └── SceneDelegate.swift
        └── Presentation
            ├── Modules
            │   ├── Home
            │   └── Login
            ├── Navigator
            │   ├── Navigator+Scene.swift
            │   ├── Navigator+Transition.swift
            │   └── Navigator.swift
            └── Views
            │   ├── Button
            │   ├── CollectionView
            │   ├── TextField
            │   └── Transition
            └── ViewIds
                └── ViewId.swift
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
- Resources: This folder contains only `resources` files, such as `.plist`, `.json`, `.tff` (fonts), `.storyboard`, `.strings`, `.der` (SSL certificates), etc.
- Sources: This folder contains only `.swift` files - the main source code of the project.

## {ProjectName}Tests

This folder contains the unit testing and integration testing of the main project.

## {ProjectName}KIFUITests

This folder contains the KIF UI testing of the main project. Use KIF instead of XCUITest for speed and reliability.
