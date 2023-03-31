//
//  Build.swift
//  FastlaneRunner
//
//  Created by Su T. on 23/09/2022.
//  Copyright © 2022 Nimble. All rights reserved.
//

enum Build {

    // MARK: Build the application

    static func adHoc(environment: Constant.Environment) {
        build(environment: environment, type: .adHoc)
    }

    static func appStore() {
        build(environment: .production, type: .appStore)
    }

    // MARK: Save the build context

    static func saveBuildContextToCI() {
        switch Constant.platform {
        case .gitHubActions:
            let ipaPath = laneContext()["IPA_OUTPUT_PATH"]
            let dsymPath = laneContext()["DSYM_OUTPUT_PATH"]
            let buildNumber = laneContext()["BUILD_NUMBER"]

            sh(command: "echo IPA_OUTPUT_PATH=\(ipaPath ?? "") >> $GITHUB_ENV")
            sh(command: "echo DSYM_OUTPUT_PATH=\(dsymPath ?? "") >> $GITHUB_ENV")
            sh(command: "echo BUILD_NUMBER=\(buildNumber ?? "") >> $GITHUB_ENV")
            sh(command: "echo VERSION_NUMBER=\(Version.versionNumber) >> $GITHUB_ENV")
        case .bitrise, .codeMagic:
            sh(command: "envman add --key BUILD_PATH --value '\(Constant.outputPath)'")
        default: break
        }
    }

    // MARK: Private

    private static func build(
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
            xcodebuildFormatter: "Pods/xcbeautify/xcbeautify"
        )
    }
}
