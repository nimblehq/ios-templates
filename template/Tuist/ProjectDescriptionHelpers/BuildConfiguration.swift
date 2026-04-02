import ProjectDescription

public enum BuildConfiguration: CaseIterable {

    case debugDev
    case releaseDev
    case debugStaging
    case releaseStaging
    case debugProduction
    case releaseProduction

    var name: ConfigurationName {
        switch self {
        case .debugDev: .configuration("Debug Dev")
        case .releaseDev: .configuration("Release Dev")
        case .debugStaging: .configuration("Debug Staging")
        case .releaseStaging: .configuration("Release Staging")
        case .debugProduction: .configuration("Debug Production")
        case .releaseProduction: .configuration("Release Production")
        }
    }

    private var path: String {
        let rootPath = "Configurations/XCConfigs/"
        switch self {
        case .debugDev:
            return "\(rootPath)DebugDev.xcconfig"
        case .releaseDev:
            return "\(rootPath)ReleaseDev.xcconfig"
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
        case .debugDev, .debugStaging, .debugProduction:
            return .debug(name: name, xcconfig: xcconfig)
        case .releaseDev, .releaseStaging, .releaseProduction:
            return .release(name: name, xcconfig: xcconfig)
        }
    }
}
