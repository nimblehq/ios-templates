//
//  Build.swift
//  FastlaneRunner
//
//  Created by Su T. on 23/09/2022.
//  Copyright © 2022 Nimble. All rights reserved.
//

final class Build {

    static func adHoc(environment: Environment) {
        build(environment: environment, type: .adHoc)
    }

    static func appStore() {
        build(environment: .production, type: .appStore)
    }

    static private func build(
        environment: Environment,
        type: BuildType
    ) {
        buildApp(
            scheme: .userDefined(environment.scheme),
            clean: .userDefined(true),
            outputName: .userDefined(environment.productName),
            includeSymbols: .userDefined(true),
            includeBitcode: .userDefined(type == .appStore),
            exportMethod: .userDefined(type.value),
            exportOptions: .userDefined([
                // NOTE: bundleId should be `env.bundleId` instead of `Constant.bundleId`
                // To test ios-template, uncomment right below
//                Constant.bundleId: "match \(type.method) \(Constant.bundleId)"
                environment.bundleId: "match \(type.method) \(environment.bundleId)"
            ]),
            buildPath: .userDefined(Constant.buildPath),
            derivedDataPath: .userDefined(Constant.derivedDataPath),
            xcodebuildFormatter: "xcpretty" // Default `xcbeautify` will never work
        )
    }
}

extension Build {

    enum Environment: String {

        case staging = "Staging"
        case production = ""

        var productName: String { "\(Constant.productName) \(rawValue)".trimmed }

        var scheme: String { "\(Constant.scheme) \(rawValue)".trimmed }

        var bundleId: String {
            let bundleId = Constant.bundleId
            switch self {
            case .staging: return "\(Constant.bundleId).\(rawValue.lowercased())"
            case .production: return bundleId
            }
        }
    }

    private enum BuildType: String {

        case adHoc = "ad-hoc"
        case appStore = "app-store"

        var value: String { return rawValue }

        var method: String {
            switch self {
            case .adHoc: return "AdHoc"
            case .appStore: return "AppStore"
            }
        }
    }
}

extension String {

    fileprivate var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}
