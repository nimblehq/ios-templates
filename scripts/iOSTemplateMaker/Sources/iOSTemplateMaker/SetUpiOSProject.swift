import Foundation
import ANSITerminal

class SetUpIOSProject {

    private let CONSTANT_PROJECT_NAME = "{PROJECT_NAME}"
    private let CONSTANT_BUNDLE_PRODUCTION = "{BUNDLE_ID_PRODUCTION}"
    private let CONSTANT_BUNDLE_STAGING = "{BUNDLE_ID_STAGING}"
    private let CONSTANT_BUNDLE_DEV = "{BUNDLE_ID_DEV}"
    private let CONSTANT_MINIMUM_VERSION = "{TARGET_VERSION}"
    private let fileManager = FileManager.default

    private var bundleIdProduction = ""
    private var bundleIdStaging = ""
    private var bundleIdDev = ""
    private var projectName = ""
    private var minimumVersion = ""
    private var cicd = ""
    private var githubRunner = ""
    private var setupConstants = false
    private var projectNameNoSpace: String { projectName.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var isCI = !((EnvironmentValue.value(for: .isCI)).string).isEmpty

    init(
        bundleIdProduction: String = "",
        bundleIdStaging: String = "",
        bundleIdDev: String = "",
        projectName: String = "",
        minimumVersion: String = "",
        cicd: String = "",
        githubRunner: String = "",
        setupConstants: Bool = false
    ) {
        self.bundleIdProduction = bundleIdProduction
        self.bundleIdStaging = bundleIdStaging
        self.bundleIdDev = bundleIdDev
        self.projectName = projectName
        self.minimumVersion = minimumVersion
        self.cicd = cicd
        self.githubRunner = githubRunner
        self.setupConstants = setupConstants
    }

    func perform() {
        do {
            try step(title: "Fill project information") {
                readArguments()
            }

            try step(title: "Replace files structure") {
                try replaceFileStructure()
            }

            try step(title: "Create placeholder files") {
                try createPlaceholderFiles()
            }

            try step(title: "Setup SwiftUI interface") {
                let swiftUIAppDirectory = "template/Tuist/Interfaces/SwiftUI/Sources/Application"
                try fileManager.rename(
                    file: "\(swiftUIAppDirectory)/App.swift",
                    to: "\(swiftUIAppDirectory)/\(projectName)App.swift"
                )
                try fileManager.moveFiles(in: "template/Tuist/Interfaces/SwiftUI/Sources", to: "template/\(projectName)/Sources")
                try fileManager.removeItems(in: "template/Tuist/Interfaces")
            }

            try step(title: "Replace package and package name within files") {
                try replaceTextInFiles()
            }

            try step(title: "Run tuist") {
                try runTuist()
            }

            try step(title: "Install dependencies") {
                try installDependencies()
            }

            try step(title: "Remove gitkeep files from project") {
                try removeGitkeepFromXcodeProject()
            }

            try step(title: "Remove template files") {
                try removeTemplateFiles()
            }

            try step(title: "Promote template to root") {
                try promoteTemplateToRoot()
            }

            try step(title: "Setup CI/CD") {
                try setUpCICD()
            }

            writeln()
            write("🚀 Done! App is ready to development 🙌", style: .success)
            try? openProject()
        } catch {
            exit(EXIT_FAILURE)
        }
    }

    private func readArguments() {
        var canMoveDown = false
        let tryMoveDown: () -> Void = {
            if canMoveDown {
                writeln()
            }

            canMoveDown = true
        }

        if isCI {
            minimumVersion = "16.0"
        }

        if bundleIdProduction.isEmpty {
            tryMoveDown()
            bundleIdProduction = ask(
                "Which is the bundle ID for the production environment?",
                note: "Ex: com.example.project",
                onValidate: validatePackageName
            )
        }

        if bundleIdStaging.isEmpty {
            tryMoveDown()
            bundleIdStaging = ask(
                "Which is the bundle ID for the staging environment?",
                note: "Ex: com.example.project.staging",
                onValidate: validatePackageName
            )
        }
        
        if bundleIdDev.isEmpty {
            tryMoveDown()
            bundleIdDev = ask(
                "Which is the bundle ID for the dev environment?",
                note: "Ex: com.example.project.dev",
                onValidate: validatePackageName
            )
        }

        if projectName.isEmpty {
            tryMoveDown()
            projectName = ask(
                "Which is the project name?",
                note: "Ex: NewProject",
                onValidate: validateProjectName
            )
        }

        if minimumVersion.isEmpty {
            tryMoveDown()

            let defaultVersion = "16.0"
            minimumVersion = ask(
                "Which is the iOS minimum version?",
                note: "Default: \(defaultVersion)",
                defaultValue: defaultVersion,
                onValidate: validateVersion
            )
        }
    }

    private func replaceFileStructure() throws {
        try fileManager.rename(file: "template/\(CONSTANT_PROJECT_NAME)Tests", to: "template/\(projectNameNoSpace)Tests")
        try fileManager.rename(file: "template/\(CONSTANT_PROJECT_NAME)UITests", to: "template/\(projectNameNoSpace)UITests")
        try fileManager.rename(file: "template/\(CONSTANT_PROJECT_NAME)", to: "template/\(projectNameNoSpace)")
    }

    private func createPlaceholderFiles() throws {
        // Duplicate the env example file to env file
        let envPath = "\(fileManager.currentDirectoryPath)/template/.env"
        if !fileManager.fileExists(atPath: envPath) {
            try fileManager.copy(file: "template/.env.example", to: "template/.env")
        }

        // Add AutoMockable.generated.swift file
        try fileManager.createFile(name: "AutoMockable.generated.swift", at: "template/\(projectNameNoSpace)Tests/Sources/Mocks/Sourcery")

        // Add R.generated.swift file.
        try fileManager.createFile(name: "R.generated.swift", at: "template/\(projectNameNoSpace)/Sources/Supports/Helpers/Rswift")
    }

    private func replaceTextInFiles() throws {
        fileManager.replaceAllOccurrences(of: CONSTANT_BUNDLE_DEV, to: bundleIdDev)
        fileManager.replaceAllOccurrences(of: CONSTANT_BUNDLE_STAGING, to: bundleIdStaging)
        fileManager.replaceAllOccurrences(of: CONSTANT_BUNDLE_PRODUCTION, to: bundleIdProduction)
        fileManager.replaceAllOccurrences(of: CONSTANT_PROJECT_NAME, to: projectNameNoSpace)
        fileManager.replaceAllOccurrences(of: CONSTANT_MINIMUM_VERSION, to: minimumVersion)
    }

    private func runTuist() throws {
        let output = try safeShell("cd template && mise trust --yes . && mise exec -- tuist install && mise exec -- tuist generate --no-open")
        if let output = output, !output.isEmpty {
            print(output)
        }

        guard fileManager.fileExists(atPath: "template/\(projectNameNoSpace).xcodeproj") else {
            throw TemplateMakerError(
                message: "Tuist failed to generate \(projectNameNoSpace).xcodeproj. Try running manually: cd template && mise exec -- tuist generate"
            )
        }
    }

    private func installDependencies() throws {
        try safeShell("cd template && bundle install")
        try safeShell("cd template && bundle exec arkana")
        // SPM dependencies are resolved automatically by Xcode, no manual installation needed
    }

    private func removeGitkeepFromXcodeProject() throws {
        let escapedProjectNameNoSpace = projectNameNoSpace.replacingOccurrences(of: ".", with: "\\.")
        try safeShell("sed -i \"\" \"s/.*\\(gitkeep\\).*,//\" template/\(escapedProjectNameNoSpace).xcodeproj/project.pbxproj")
    }

    private func removeTemplateFiles() throws {
        // Note: .mise.toml is kept as it's the source of truth for tool versions
        // .tuist-version is removed if it exists (for backward compatibility cleanup)
        try fileManager.removeItems(in: "template/.tuist-version")
        try fileManager.removeItems(in: "template/Tuist")
        try fileManager.removeItems(in: "template/Project.swift")
    }

    private func promoteTemplateToRoot() throws {
        // Promote generated files over the repository template files in one pass.
        // Overwrite is important here because files like README.md / AGENTS.md / CLAUDE.md
        // already exist at the repo root while we are generating in-place during CI.
        try fileManager.moveFiles(in: "template", to: ".", overwrite: true)
        try fileManager.removeItems(in: "template")

        // Use exact case-sensitive matching to avoid accidentally removing the generated project
        // folder when its name is a case-insensitive match of a repo directory (e.g. "Sample" vs "sample")
        let rootContents = (try? fileManager.contentsOfDirectory(atPath: fileManager.currentDirectoryPath)) ?? []
        for name in ["sample", "scripts", ".github", ".git/index"] where rootContents.contains(name) {
            try fileManager.removeItems(in: name)
        }
        try safeShell("git reset")
    }

    private func setUpCICD() throws {
        if !isCI {
            try SetUpCICDService().perform(cicd: cicd, githubRunner: githubRunner)
            try SetUpDeliveryConstants().perform(setupConstants: setupConstants)
        }
    }

    private func openProject() throws {
        if !isCI {
            // Using Xcode's native SPM integration, so we open the project file directly.
            // Packages are integrated into the project and appear in Package Dependencies.
            let projectFile = "\(projectNameNoSpace).xcodeproj"
            try safeShell("open -a Xcode \(projectFile)")
        }
    }

    private func validatePackageName(_ name: String) -> String? {
        let packageNameRegex="^[a-z][a-z0-9_]*(\\.[a-z0-9_-]+)+[0-9a-z_-]$"
        let valid = name ~= packageNameRegex

        return valid ? nil : "Please pick a valid package name with pattern {com.example.package}"
    }

    private func validateProjectName(_ name: String) -> String? {
        name.isEmpty ? "Please input the project name" : nil
    }


    private func validateVersion(_ version: String) -> String? {
        if version.isEmpty {
            return nil
        }

        let versionRegex="^[0-9_]+(\\.[0-9]+)+$"
        let valid = version ~= versionRegex

        return valid ? nil : "Please pick a valid version with pattern {x.y}"
    }
}
