//
//  Build.swift
//  FastlaneRunner
//
//  Created by Su T. on 23/09/2022.
//  Copyright © 2022 Nimble. All rights reserved.
//

enum Build {

    static func saveBuildContextToCI() {
        switch Constant.platform {
        case .bitriseIO:
            let ipaPath = laneContext()["IPA_OUTPUT_PATH"]
            let dsymPath = laneContext()["DSYM_OUTPUT_PATH"]
            let buildNumber = laneContext()["BUILD_NUMBER"]

            sh(command: "echo IPA_OUTPUT_PATH=\(ipaPath ?? "") >> $GITHUB_ENV")
            sh(command: "echo DSYM_OUTPUT_PATH=\(dsymPath ?? "") >> $GITHUB_ENV")
            sh(command: "echo BUILD_NUMBER=\(buildNumber ?? "") >> $GITHUB_ENV")
            sh(command: "echo VERSION_NUMBER=\(Version.versionNumber) >> $GITHUB_ENV")
        case .gitHubAction:
            sh(command: "envman add --key BUILD_PATH --value '\(Constant.outputPath)'")
        default: break
        }
    }

    static func adHoc(environment: Constant.Environment) {
        build(environment: environment, type: .adHoc)
    }

    static func appStore() {
        build(environment: .production, type: .appStore)
    }

    static private func build(
        environment: Constant.Environment,
        type: Constant.BuildType
    ) {
        buildApp(
            scheme: .userDefined(environment.scheme),
            clean: .userDefined(true),
            outputDirectory: Constant.outputPath,
            outputName: .userDefined(environment.productName),
            includeSymbols: .userDefined(true),
            exportMethod: .userDefined(type.value),
            exportOptions: .userDefined([
                "provisioningProfiles": [
                    environment.bundleId: "match \(type.method) \(environment.bundleId)"
                ]
            ]),
            buildPath: .userDefined(Constant.buildPath),
            derivedDataPath: .userDefined(Constant.derivedDataPath),
            xcodebuildFormatter: "xcpretty" // Default `xcbeautify` will never work
        )
    }
}
