import ProjectDescription

public enum BuildConfiguration: CaseIterable {

    case debugStaging
    case releaseStaging
    case debugProduction
    case releaseProduction

    public var name: ConfigurationName {
        switch self {
        case .debugStaging: .configuration("Debug Staging")
        case .releaseStaging: .configuration("Release Staging")
        case .debugProduction: .configuration("Debug Production")
        case .releaseProduction: .configuration("Release Production")
        }
    }

    private var path: String {
        let rootPath = "Configurations/XCConfigs/"
        switch self {
        case .debugStaging:
            return "\(rootPath)DebugStaging.xcconfig"
        case .releaseStaging:
            return "\(rootPath)ReleaseStaging.xcconfig"
        case .debugProduction:
            return "\(rootPath)DebugProduction.xcconfig"
        case .releaseProduction:
            return "\(rootPath)ReleaseProduction.xcconfig"
        }
    }

    /// Creates a configuration with an xcconfig path relative to the App's Project.swift location.
    public func createConfiguration() -> Configuration {
        let xcconfig = Path(stringLiteral: path)
        switch self {
        case .debugStaging, .debugProduction:
            return .debug(name: name, xcconfig: xcconfig)
        case .releaseStaging, .releaseProduction:
            return .release(name: name, xcconfig: xcconfig)
        }
    }
}
