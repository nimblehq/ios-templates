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
}
