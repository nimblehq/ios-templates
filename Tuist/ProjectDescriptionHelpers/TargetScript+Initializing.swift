import ProjectDescription

extension TargetScript {

    public static func sourceryAction() -> TargetScript {
        let sourceryPath = "$PODS_ROOT/Sourcery/bin/sourcery"
        return .pre(
            script: "\"\(sourceryPath)\"",
            name: "Sourcery",
            basedOnDependencyAnalysis: true
        )
    }

    public static func rswiftAction() -> TargetScript {
        let rswiftPath = "$PODS_ROOT/R.swift/rswift"
        let outputPath = "$SRCROOT/$PROJECT_NAME/Sources/Supports/Helpers/Rswift/R.generated.swift"
        return .pre(
            script: "\"\(rswiftPath)\" generate \"\(outputPath)\"",
            name: "R.swift",
            outputPaths: ["\(outputPath)"],
            basedOnDependencyAnalysis: false
        )
    }

    public static func swiftLintAction() -> TargetScript {
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

    public static func swiftFormatAction() -> TargetScript {
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

    public static func swiftFormatLintAction() -> TargetScript {
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

    public static func firebaseAction() -> TargetScript {
        let script = """
        PATH_TO_GOOGLE_PLISTS="$SRCROOT/$PROJECT_NAME/Configurations/Plists/GoogleService"

        case "${CONFIGURATION}" in
        "\(BuildConfiguration.debugStaging.name)" | "\(BuildConfiguration.releaseStaging.name)" )
        cp -r "$PATH_TO_GOOGLE_PLISTS/Staging/GoogleService-Info.plist" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"
        ;;
        "\(BuildConfiguration.debugProduction.name)" | "\(BuildConfiguration.releaseProduction.name)" )
        cp -r "$PATH_TO_GOOGLE_PLISTS/Production/GoogleService-Info.plist" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"
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
