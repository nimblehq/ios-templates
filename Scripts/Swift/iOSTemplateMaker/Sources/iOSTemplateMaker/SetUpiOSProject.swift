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
    private var interface: SetUpInterface.Interface?
    private var projectNameNoSpace: String { projectName.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var isCI = !((EnvironmentValue.value(for: .isCI)).string).isEmpty

    init(
        bundleIdProduction: String = "",
        bundleIdStaging: String = "",
        bundleIdDev: String = "",
        projectName: String = "",
        minimumVersion: String = "",
        interface: String = ""
    ) {
        self.bundleIdProduction = bundleIdProduction
        self.bundleIdStaging = bundleIdStaging
        self.bundleIdDev = bundleIdDev
        self.projectName = projectName
        self.minimumVersion = minimumVersion
        self.interface = .init(interface)
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

            try step(title: "Setup interface") {
                try SetUpInterface().perform(interface ?? .uiKit, projectName)
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

            try step(title: "Setup CI/CD") {
                try setUpCICD()
            }

            writeln()
            write("🚀 Done! App is ready to development 🙌", style: .success)
            try? openProject()
        } catch {}
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
            minimumVersion = "15.0"
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
            bundleIdProduction = ask(
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
        if interface == nil {
            tryMoveDown()

            interface = picker(
                title: "Which is the interface",
                options: SetUpInterface.Interface.allCases
            )
        }
    }

    private func replaceFileStructure() throws {
        try fileManager.rename(file: "\(CONSTANT_PROJECT_NAME)Tests", to: "\(projectNameNoSpace)Tests")
        try fileManager.rename(file: "\(CONSTANT_PROJECT_NAME)KIFUITests", to: "\(projectNameNoSpace)KIFUITests")
        try fileManager.rename(file: "\(CONSTANT_PROJECT_NAME)", to: "\(projectNameNoSpace)")
    }

    private func createPlaceholderFiles() throws {
        // Duplicate the env example file to env file
        try fileManager.copy(file: ".env.example", to: ".env")

        // Add AutoMockable.generated.swift file
        try fileManager.createFile(name: "AutoMockable.generated.swift", at: "\(projectNameNoSpace)Tests/Sources/Mocks/Sourcery")

        // Add R.generated.swift file.
        try fileManager.createFile(name: "R.generated.swift", at: "\(projectNameNoSpace)/Sources/Supports/Helpers/Rswift")
    }

    private func replaceTextInFiles() throws {
        fileManager.replaceAllOccurrences(of: CONSTANT_BUNDLE_DEV, to: bundleIdDev)
        fileManager.replaceAllOccurrences(of: CONSTANT_BUNDLE_STAGING, to: bundleIdStaging)
        fileManager.replaceAllOccurrences(of: CONSTANT_BUNDLE_PRODUCTION, to: bundleIdProduction)
        fileManager.replaceAllOccurrences(of: CONSTANT_PROJECT_NAME, to: projectNameNoSpace)
        fileManager.replaceAllOccurrences(of: CONSTANT_MINIMUM_VERSION, to: minimumVersion)
    }

    private func installTuistIfNeeded() throws {
        let tuistLocation = try safeShell("command -v tuist")
        if let tuistLocation, tuistLocation.isEmpty {
            print("Tuist could not be found")
            print("Installing tuist")
            try safeShell(
                """
                    readonly TUIST_VERSION=`cat .tuist-version`
                    curl -Ls https://install.tuist.io | bash
                    tuist install ${TUIST_VERSION}
                """
            )
        }
    }

    private func runTuist() throws {
        try installTuistIfNeeded()
        try safeShell("tuist generate --no-open")
    }

    private func installDependencies() throws {
        try safeShell("bundle install")
        try safeShell("bundle exec arkana")
        try safeShell("bundle exec pod install --repo-update")
    }

    private func removeGitkeepFromXcodeProject() throws {
        let escapedProjectNameNoSpace = projectNameNoSpace.replacingOccurrences(of: ".", with: "\\.")
        try safeShell("sed -i \"\" \"s/.*\\(gitkeep\\).*,//\" \(escapedProjectNameNoSpace).xcodeproj/project.pbxproj")
    }

    private func removeTemplateFiles() throws {
        try fileManager.removeItems(in: ".tuist-version")
        try fileManager.removeItems(in: "tuist")
        try fileManager.removeItems(in: "Project.swift")
        try fileManager.removeItems(in: "Workspace.swift")

        try fileManager.removeItems(in: ".github/workflows/test_uikit_install_script.yml")
        try fileManager.removeItems(in: ".github/workflows/test_swiftui_install_script.yml")
        try fileManager.removeItems(in: ".git/index")
        try safeShell("git reset")
    }

    private func setUpCICD() throws {
        if !isCI {
            try SetUpCICDService().perform()
            try SetUpDeliveryConstants().perform()
            try fileManager.removeItems(in: "Scripts")
        }
    }

    private func openProject() throws {
        if !isCI {
            try safeShell("open -a Xcode \(projectNameNoSpace).xcworkspace")
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
