import ProjectDescription

extension TargetScript {

    public static func sourceryScript() -> TargetScript {
        let sourceryPath = "$PODS_ROOT/Sourcery/bin/sourcery"
        return .pre(
            script: "\"\(sourceryPath)\"",
            name: "Sourcery",
            basedOnDependencyAnalysis: true
        )
    }

    public static func rswiftScript() -> TargetScript {
        let rswiftPath = "$PODS_ROOT/R.swift/rswift"
        let outputPath = "$SRCROOT/$PROJECT_NAME/Sources/Supports/Helpers/Rswift/R.generated.swift"
        return .pre(
            script: "\"\(rswiftPath)\" generate \"\(outputPath)\"",
            name: "R.swift",
            outputPaths: ["\(outputPath)"],
            basedOnDependencyAnalysis: false
        )
    }

    public static func swiftLintScript() -> TargetScript {
        let swiftLintPath = """
        if [ -z "$CI" ]; then
            ${PODS_ROOT}/SwiftLint/swiftlint
        fi
        """
        return .pre(
            script: swiftLintPath,
            name: "SwiftLint",
            basedOnDependencyAnalysis: true
        )
    }

    public static func swiftFormatScript() -> TargetScript {
        let runSwiftFormat = """
        if [ -z "$CI" ]; then
            "${PODS_ROOT}/SwiftFormat/CommandLineTool/swiftformat" "$SRCROOT"
        fi
        """
        return .pre(
            script: runSwiftFormat,
            name: "SwiftFormat",
            basedOnDependencyAnalysis: true
        )
    }

    public static func swiftFormatLintScript() -> TargetScript {
        let runSwiftFormat = """
        if [ -z "$CI" ]; then
            "${PODS_ROOT}/SwiftFormat/CommandLineTool/swiftformat" "$SRCROOT" --lint --lenient
        fi
        """
        return .pre(
            script: runSwiftFormat,
            name: "SwiftFormat Lint",
            basedOnDependencyAnalysis: true
        )
    }

    public static func firebaseScript() -> TargetScript {
        let debugStagingName = BuildConfiguration.debugStaging.name.rawValue
        let releaseStagingName = BuildConfiguration.releaseStaging.name.rawValue
        let debugProductionName = BuildConfiguration.debugProduction.name.rawValue
        let releaseProductionName = BuildConfiguration.releaseProduction.name.rawValue
        let googleServicePath = "$SRCROOT/$PROJECT_NAME/Configurations/Plists/GoogleService"
        let stagingPlistPath = "$PATH_TO_GOOGLE_PLISTS/Staging/GoogleService-Info.plist"
        let productionPlistPath = "$PATH_TO_GOOGLE_PLISTS/Production/GoogleService-Info.plist"
        let appPlistPath = "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"

        let script = """
        PATH_TO_GOOGLE_PLISTS="\(googleServicePath)"

        case "${CONFIGURATION}" in
        "\(debugStagingName)" | "\(releaseStagingName)" )
        cp -r "\(stagingPlistPath)" "\(appPlistPath)"
        ;;
        "\(debugProductionName)" | "\(releaseProductionName)" )
        cp -r "\(productionPlistPath)" "\(appPlistPath)"
        ;;
        *)
        ;;
        esac
        """

        return .post(
            script: script,
            name: "Copy GoogleService-Info.plist",
            basedOnDependencyAnalysis: true
        )
    }
}
