//
//  Build.swift
//  FastlaneRunner
//
//  Created by Su T. on 23/09/2022.
//  Copyright © 2022 Nimble. All rights reserved.
//

enum Build {

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
