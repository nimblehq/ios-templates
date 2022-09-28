//
//  Version.swift
//  FastlaneRunner
//
//  Created by Khanh on 26/09/2022.
//  Copyright © 2022 Nimble. All rights reserved.
//

enum Version {
    
    // MARK: - Getting

    static func getVersionNumber() -> String {
        FastlaneRunner.getVersionNumber(
            xcodeproj: .userDefined(Constant.projectPath),
            target: .userDefined(Constant.projectName)
        )
    }

    static func getBuildNumber() -> String {
        FastlaneRunner.getBuildNumber(
            xcodeproj: .userDefined(Constant.projectPath)
        )
    }

    static func getVersionAndBuildNumber() -> String {
        "\(getVersionNumber()) (Build: \(getBuildNumber())"
    }

    static var releaseTag: String {
        "release/\(getVersionNumber())/\(numberOfCommits())"
    }

    // MARK: - Setting
    static func setVersionNumber() {
        incrementVersionNumber(
            versionNumber: .userDefined(getVersionNumber()),
            xcodeproj: .userDefined(Constant.projectPath)
        )
    }

    static func setBuildNumber() {
        incrementBuildNumber(
            buildNumber: .userDefined(getBuildNumber()),
            xcodeproj: .userDefined(Constant.projectPath)
        )
    }
}
