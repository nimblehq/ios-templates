import ProjectDescription

public enum BuildConfiguration: CaseIterable {

    case debugStaging
    case releaseStaging
    case debugProduction
    case releaseProduction

    var name: ConfigurationName {
        switch self {
        case .debugStaging: return ConfigurationName.configuration("Debug Staging")
        case .releaseStaging: return ConfigurationName.configuration("Release Staging")
        case .debugProduction: return ConfigurationName.configuration("Debug Production")
        case .releaseProduction: return ConfigurationName.configuration("Release Production")
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

    public func createConfiguration(projectName: String) -> Configuration {
        let xcconfig = Path("\(projectName)/\(path)")
        switch self {
        case .debugStaging, .debugProduction:
            return .debug(name: name, xcconfig: xcconfig)
        case .releaseStaging, .releaseProduction:
            return .release(name: name, xcconfig: xcconfig)
        }
    }
}
