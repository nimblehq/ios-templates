//
//  Test.swift
//  FastlaneRunner
//
//  Created by Khanh on 27/09/2022.
//  Copyright © 2022 Nimble. All rights reserved.
//

enum Test {

    static func buildAndTest(
        environment: Constant.Environment,
        targets: [String],
        devices: [String]
    ) {
        scan(
            scheme: .userDefined(environment.scheme),
            devices: .userDefined(devices),
            onlyTesting: targets,
            codeCoverage: .userDefined(true),
            outputDirectory: Constant.testOutputDirectoryPath,
            xcodebuildFormatter: "xcpretty",
            resultBundle: .userDefined(true),
            failBuild: .userDefined(false)
        )
    }
    
    static func setAppIcon() {
        appicon(
            appiconImageFile: "fastlane/Icon/appicon.png",
            appiconDevices: ["iphone"],
            appiconPath: "\(Constant.projectName)/Resources/Assets/Assets.xcassets"
        )
        disableExemptEncryption()
    }

    static private func disableExemptEncryption() {
        setInfoPlistValue(
            key: "ITSAppUsesNonExemptEncryption",
            value: "false",
            path: "\(Constant.projectName)/Configurations/Plists/Info.plist"
        )
    }
}
