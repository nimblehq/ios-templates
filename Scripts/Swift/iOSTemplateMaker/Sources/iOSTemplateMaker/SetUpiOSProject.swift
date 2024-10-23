import Foundation

class SetUpIOSProject {

    private let CONSTANT_PROJECT_NAME = "{PROJECT_NAME}"
    private let CONSTANT_BUNDLE_PRODUCTION = "{BUNDLE_ID_PRODUCTION}"
    private let CONSTANT_BUNDLE_STAGING = "{BUNDLE_ID_STAGING}"
    private let CONSTANT_MINIMUM_VERSION = "{TARGET_VERSION}"
    private let fileManager = FileManager.default

    private var bundleIdProduction = ""
    private var bundleIdStaging = ""
    private var projectName = ""
    private var minimumVersion = ""
    private var interface: SetUpInterface.Interface?
    private var projectNameNoSpace: String { projectName.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var isCI = !((EnvironmentValue.value(for: .isCI)).string).isEmpty

    init(
        bundleIdProduction: String = "",
        bundleIdStaging: String = "",
        projectName: String = "",
        minimumVersion: String = "",
        interface: String = ""
    ) {
        self.bundleIdProduction = bundleIdProduction
        self.bundleIdStaging = bundleIdStaging
        self.projectName = projectName
        self.minimumVersion = minimumVersion
        self.interface = .init(interface)
    }

    func perform() {
        readArguments()
        print("=> 🐢 Starting init \(projectName) ...")
        replaceFileStructure()
        createPlaceholderFiles()
        SetUpInterface().perform(interface ?? .uiKit, projectName)
        try? replaceTextInFiles()
        try? runTuist()
        try? installDependencies()
        try? removeGitkeepFromXcodeProject()
        try? removeTemplateFiles()
        setUpCICD()

        print("=> 🚀 Done! App is ready to be tested 🙌")
        try? openProject()
    }

    private func readArguments() {
        if isCI {
            minimumVersion = "14.0"
        }

        while bundleIdProduction.isEmpty || !checkPackageName(bundleIdProduction) {
            print("BUNDLE ID PRODUCTION (i.e. com.example.project):")
            bundleIdProduction = readLine().string
        }
        while bundleIdStaging.isEmpty || !checkPackageName(bundleIdStaging)  {
            print("BUNDLE ID STAGING (i.e. com.example.project.staging):")
            bundleIdStaging = readLine().string
        }
        while projectName.isEmpty {
            print("PROJECT NAME (i.e. NewProject):")
            projectName = readLine().string
        }
        while minimumVersion.isEmpty || !checkVersion(minimumVersion) {
            print("iOS Minimum Version (i.e. 14.0):")
            let version = readLine().string
            minimumVersion = !version.isEmpty ? version : "14.0"
        }
        while interface == nil {
            print("Interface [(S)wiftUI or (U)IKit]:")
            interface = SetUpInterface.Interface(readLine().string)
        }
    }

    private func replaceFileStructure() {
        print("=> 🔎 Replacing files structure...")
        fileManager.rename(file: "\(CONSTANT_PROJECT_NAME)Tests", to: "\(projectNameNoSpace)Tests")
        fileManager.rename(file: "\(CONSTANT_PROJECT_NAME)KIFUITests", to: "\(projectNameNoSpace)KIFUITests")
        fileManager.rename(file: "\(CONSTANT_PROJECT_NAME)", to: "\(projectNameNoSpace)")
        fileManager.removeItems(in: "README.md")
        fileManager.rename(file: "PROJECT_README.md", to: "README.md")
    }

    private func createPlaceholderFiles() {
        // Duplicate the env example file to env file
        fileManager.copy(file: ".env.example", to: ".env")

        // Add AutoMockable.generated.swift file
        fileManager.createFile(name: "AutoMockable.generated.swift", at: "\(projectNameNoSpace)Tests/Sources/Mocks/Sourcery")

        // Add R.generated.swift file.
        fileManager.createFile(name: "R.generated.swift", at: "\(projectNameNoSpace)/Sources/Supports/Helpers/Rswift")
    }

    private func replaceTextInFiles() throws {
        print("=> 🔎 Replacing package and package name within files...")
        fileManager.replaceAllOccurrences(of: CONSTANT_BUNDLE_STAGING, to: bundleIdStaging)
        fileManager.replaceAllOccurrences(of: CONSTANT_BUNDLE_PRODUCTION, to: bundleIdProduction)
        fileManager.replaceAllOccurrences(of: CONSTANT_PROJECT_NAME, to: projectNameNoSpace)
        fileManager.replaceAllOccurrences(of: CONSTANT_MINIMUM_VERSION, to: minimumVersion)
        print("✅  Completed")
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
        print("✅  Completed")
    }

    private func installDependencies() throws {
        print("Installing gems")
        try safeShell("bundle install")

        // Install dependencies
        print("Run Arkana")
        try safeShell("bundle exec arkana")

        print("Installing pod dependencies")
        try safeShell("bundle exec pod install --repo-update")
        print("✅  Completed")
    }

    private func removeGitkeepFromXcodeProject() throws {
        print("Remove gitkeep files from project")
        let escapedProjectNameNoSpace = projectNameNoSpace.replacingOccurrences(of: ".", with: "\\.")
        try safeShell("sed -i \"\" \"s/.*\\(gitkeep\\).*,//\" \(escapedProjectNameNoSpace).xcodeproj/project.pbxproj")
        print("✅  Complete")
    }

    private func removeTemplateFiles() throws {
        print("Remove tuist files")
        fileManager.removeItems(in: ".tuist-version")
        fileManager.removeItems(in: "tuist")
        fileManager.removeItems(in: "Project.swift")
        fileManager.removeItems(in: "Workspace.swift")

        print("Remove script files and git/index")
        fileManager.removeItems(in: ".github/workflows/test_uikit_install_script.yml")
        fileManager.removeItems(in: ".github/workflows/test_swiftui_install_script.yml")
        fileManager.removeItems(in: ".git/index")
        try safeShell("git reset")
    }

    private func setUpCICD() {
        if !isCI {
            SetUpCICDService().perform()
            SetUpDeliveryConstants().perform()
            fileManager.removeItems(in: "Scripts")
        }
        print("✅  Completed")
    }

    private func openProject() throws {
        if !isCI {
            print("=> 🛠 Opening the project.")
            try safeShell("open -a Xcode \(projectNameNoSpace).xcworkspace")
        }
    }

    private func checkPackageName(_ name: String) -> Bool {
        let packageNameRegex="^[a-z][a-z0-9_]*(\\.[a-z0-9_-]+)+[0-9a-z_-]$"
        let valid = name ~= packageNameRegex
        if !valid {
            print("Please pick a valid package name with pattern {com.example.package}")
        }
        return valid
    }

    private func checkVersion(_ version: String) -> Bool {
        let versionRegex="^[0-9_]+(\\.[0-9]+)+$"
        let valid = version ~= versionRegex
        if !valid {
            print("Please pick a valid version with pattern {x.y}")
        }
        return valid
    }
}
