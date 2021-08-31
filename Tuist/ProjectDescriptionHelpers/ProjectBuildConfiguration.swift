import ProjectDescription

public enum ProjectBuildConfiguration: CaseIterable {

    case debugStaging
    case releaseStaging
    case debugProduction
    case releaseProduction

    private var name: String {
        switch self {
        case .debugStaging: return "Debug Staging"
        case .releaseStaging: return "Release Staging"
        case .debugProduction: return "Debug Production"
        case .releaseProduction: return "Release Production"
        }
    }

    private var xcconfigPath: String {
        let rootPath = "Configurations/XCConfigs/"
        switch self {
            case .debugStaging:
                return rootPath += "DebugStaging.xcconfig"
            case .releaseStaging:
                return rootPath += "ReleaseStaging.xcconfig"
            case .debugProduction:
                return rootPath += "DebugProduction.xcconfig"
            case .releaseProduction:
                return rootPath += "ReleaseProduction.xcconfig"
        }
    }

    public func createConfiguration(projectName: String) -> CustomConfiguration {
        let xcconfigPath = Path("\(projectName)/\(xcconfigPath)")
        switch self {
        case .debugStaging, .debugProduction:
            return .debug(name: name, xcconfig: xcconfigPath)
        case .releaseStaging, .releaseProduction:
            return .release(name: name, xcconfig: xcconfigPath)
        }
    }
}
