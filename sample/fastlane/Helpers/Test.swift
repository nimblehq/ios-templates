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
        onlyTesting: [String] = [],
        devices: [String]
    ) {
        // Debug: Print test configuration
        echo(message: "🔍 Test Configuration Debug:")
        echo(message: "  - Environment: \(environment.rawValue)")
        echo(message: "  - Scheme: \(environment.scheme)")
        echo(message: "  - Devices: \(devices.joined(separator: ", "))")
        echo(message: "  - Only Testing: \(onlyTesting.isEmpty ? "All tests" : onlyTesting.joined(separator: ", "))")
        echo(message: "  - Output Directory: \(Constant.testOutputDirectoryPath)")
        
        scan(
            scheme: .userDefined(environment.scheme),
            devices: .userDefined(devices),
            onlyTesting: onlyTesting,
            codeCoverage: .userDefined(true),
            outputDirectory: Constant.testOutputDirectoryPath,
            resultBundle: .userDefined(true),
            xcargs: .userDefined("-verbose"),
            failBuild: .userDefined(false)
        )
    }

    static func disableExemptEncryption() {
        setInfoPlistValue(
            key: "ITSAppUsesNonExemptEncryption",
            value: "false",
            path: "\(Constant.projectName)/Configurations/Plists/Info.plist"
        )
    }
}
