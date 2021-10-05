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
        let swiftFormatPath = "BuildTools"
        let runSwiftFormat = """
        SDKROOT=(xcrun --sdk macosx --show-sdk-path)
        #swift package update #Uncomment this line temporarily to update the version used to the latest matching your BuildTools/Package.swift file
        swift run -c release swiftformat \"$SRCROOT\"
        """
        let script = """
        cd \(swiftFormatPath)
        \(runSwiftFormat)
        """
        return .pre(
            script: script,
            name: "SwiftFormat",
            basedOnDependencyAnalysis: true
        )
    }
}
