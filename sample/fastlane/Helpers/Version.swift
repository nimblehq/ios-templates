//
//  Version.swift
//  FastlaneRunner
//
//  Created by Khanh on 26/09/2022.
//  Copyright © 2022 Nimble. All rights reserved.
//

enum Version {

    // MARK: - Getting

    static var versionNumber: String {
        get {
            FastlaneRunner.getVersionNumber(
                xcodeproj: .userDefined(Constant.projectPath),
                target: .userDefined(Constant.projectName)
            )
        }

        set {
            incrementVersionNumber(
                versionNumber: .userDefined(newValue),
                xcodeproj: .userDefined(Constant.projectPath)
            )
        }
    }

    static var buildNumber: String {
        get {
            FastlaneRunner.getBuildNumber(xcodeproj: .userDefined(Constant.projectPath))
        }

        set {
            incrementBuildNumber(
                buildNumber: .userDefined(newValue),
                xcodeproj: .userDefined(Constant.projectPath)
            )
        }
    }

    static func getVersionAndBuildNumber() -> String {
        "\(versionNumber) (Build: \(buildNumber)"
    }

    static var releaseTag: String {
        "release/\(versionNumber)"
    }
}
