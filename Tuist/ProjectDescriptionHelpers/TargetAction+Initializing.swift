import ProjectDescription

extension TargetAction {

    public static func sourceryAction() -> TargetAction {
        let sourceryPath = "$PODS_ROOT/Sourcery/bin/sourcery"
        return .pre(
            script: "\"\(sourceryPath)\"",
            name: "Sourcery",
            basedOnDependencyAnalysis: true
        )
    }

    public static func rswiftAction() -> TargetAction {
        let rswiftPath = "$PODS_ROOT/R.swift/rswift"
        let inputPath = "$TEMP_DIR/rswift-lastrun"
        let outputPath = "$SRCROOT/$PROJECT_NAME/Sources/Supports/Helpers/R.swift/R.generated.swift"
        return .pre(
            script: "\"\(rswiftPath)\" generate \"\(outputPath)\"",
            name: "R.swift",
            inputPaths: ["\(inputPath)"],
            outputPaths: ["\(outputPath)"],
            basedOnDependencyAnalysis: true
        )
    }

    public static func swiftLintAction() -> TargetAction {
        let swiftLintPath = "${PODS_ROOT}/SwiftLint/swiftlint"
        return .pre(
            script: "\"\(swiftLintPath)\"",
            name: "SwiftLint",
            basedOnDependencyAnalysis: true
        )
    }

    public static func swiftFormatAction() -> TargetAction {
        let runSwiftFormat = """
        "${PODS_ROOT}/SwiftFormat/CommandLineTool/swiftformat" "$SRCROOT"
        """
        return .pre(
            script: runSwiftFormat,
            name: "SwiftFormat",
            basedOnDependencyAnalysis: true
        )
    }

    public static func firebaseAction() -> TargetAction {
        let script = """
        PATH_TO_GOOGLE_PLISTS="$SRCROOT/$PROJECT_NAME/Configurations/Plists/GoogleService"

        case "${CONFIGURATION}" in
        "\(ProjectBuildConfiguration.debugStaging.name)" | "\(ProjectBuildConfiguration.releaseStaging.name)" )
        cp -r "$PATH_TO_GOOGLE_PLISTS/Staging/GoogleService-Info.plist" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"
        ;;
        "\(ProjectBuildConfiguration.debugProduction.name)" | "\(ProjectBuildConfiguration.releaseProduction.name)" )
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
