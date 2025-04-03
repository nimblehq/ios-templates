import Foundation
import ANSITerminal

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
    private var dependencyManager: SetUpDependencyManager.DependencyManager?
    private var verbose: Bool = false

    private func verbosePrint(_ message: String) {
        if verbose {
            print(message)
        }
    }

    init(
        bundleIdProduction: String = "",
        bundleIdStaging: String = "",
        projectName: String = "",
        minimumVersion: String = "",
        interface: String = "",
        dependencyManager: String = "",
        verbose: Bool = false
    ) {
        self.bundleIdProduction = bundleIdProduction
        self.bundleIdStaging = bundleIdStaging
        self.projectName = projectName
        self.minimumVersion = minimumVersion
        self.interface = .init(interface)
        self.dependencyManager = .init(dependencyManager)
        self.verbose = verbose
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

            try step(title: "Install dependencies") {
                try installDependencies()
            }

            try step(title: "Run tuist") {
                try runTuist()
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

        if dependencyManager == nil {
            tryMoveDown()

            dependencyManager = picker(
                title: "Which dependency manager would you like to use?",
                options: SetUpDependencyManager.DependencyManager.allCases
            )
        }
    }

    private func replaceFileStructure() throws {
        verbosePrint("🔄 Replacing file structure...")
        verbosePrint("📝 Project name: \(projectNameNoSpace)")

        let currentDirectory = fileManager.currentDirectoryPath
        verbosePrint("📂 Current directory: \(currentDirectory)")

        // List directory contents before renaming
        if let contents = try? fileManager.contentsOfDirectory(atPath: currentDirectory) {
            verbosePrint("📋 Directory contents before renaming:")
            contents.forEach { verbosePrint("   - \($0)") }
        }

        // Recursively rename all files and folders containing placeholders
        try recursivelyRenamePlaceholders(in: currentDirectory)

        // Recursively replace all placeholders in file contents
        try recursivelyReplacePlaceholdersInFiles(in: currentDirectory)

        // List directory contents after renaming and replacement
        if let contents = try? fileManager.contentsOfDirectory(atPath: currentDirectory) {
            verbosePrint("📋 Directory contents after renaming and replacement:")
            contents.forEach { verbosePrint("   - \($0)") }
        }

        verbosePrint("✅ File structure replacement completed")
    }

    /// Recursively renames all files and folders containing placeholders in their names
    private func recursivelyRenamePlaceholders(in directory: String) throws {
        let fileManager = FileManager.default
        let contents = try fileManager.contentsOfDirectory(atPath: directory)
        for item in contents {
            let itemPath = (directory as NSString).appendingPathComponent(item)
            var isDir: ObjCBool = false
            fileManager.fileExists(atPath: itemPath, isDirectory: &isDir)

            var newItemPath = itemPath
            var renamed = false
            var newName = item

            // Rename if the item name contains any placeholder
            if item.contains(CONSTANT_PROJECT_NAME) {
                newName = newName.replacingOccurrences(of: CONSTANT_PROJECT_NAME, with: projectNameNoSpace)
                renamed = true
            }
            if item.contains(CONSTANT_BUNDLE_PRODUCTION) {
                newName = newName.replacingOccurrences(of: CONSTANT_BUNDLE_PRODUCTION, with: bundleIdProduction)
                renamed = true
            }
            if item.contains(CONSTANT_BUNDLE_STAGING) {
                newName = newName.replacingOccurrences(of: CONSTANT_BUNDLE_STAGING, with: bundleIdStaging)
                renamed = true
            }
            if item.contains(CONSTANT_MINIMUM_VERSION) {
                newName = newName.replacingOccurrences(of: CONSTANT_MINIMUM_VERSION, with: minimumVersion)
                renamed = true
            }

            if renamed {
                let updatedPath = (directory as NSString).appendingPathComponent(newName)
                verbosePrint("📦 Renaming \(itemPath) to \(updatedPath)")
                try fileManager.moveItem(atPath: itemPath, toPath: updatedPath)
                newItemPath = updatedPath
            }

            // Recursively process subdirectories (use new path if renamed)
            if isDir.boolValue {
                try recursivelyRenamePlaceholders(in: newItemPath)
            }
        }
    }

    /// Recursively replaces all placeholders in file contents
    private func recursivelyReplacePlaceholdersInFiles(in directory: String) throws {
        let fileManager = FileManager.default
        let contents = try fileManager.contentsOfDirectory(atPath: directory)
        for item in contents {
            let itemPath = (directory as NSString).appendingPathComponent(item)
            var isDir: ObjCBool = false
            fileManager.fileExists(atPath: itemPath, isDirectory: &isDir)

            if isDir.boolValue {
                try recursivelyReplacePlaceholdersInFiles(in: itemPath)
            } else {
                // Only process regular files (skip binary files by extension if needed)
                if let data = try? Data(contentsOf: URL(fileURLWithPath: itemPath)),
                   let text = String(data: data, encoding: .utf8) {
                    var newText = text
                    newText = newText.replacingOccurrences(of: CONSTANT_PROJECT_NAME, with: projectNameNoSpace)
                    newText = newText.replacingOccurrences(of: CONSTANT_BUNDLE_PRODUCTION, with: bundleIdProduction)
                    newText = newText.replacingOccurrences(of: CONSTANT_BUNDLE_STAGING, with: bundleIdStaging)
                    newText = newText.replacingOccurrences(of: CONSTANT_MINIMUM_VERSION, with: minimumVersion)
                    if newText != text {
                        verbosePrint("✏️ Replacing placeholders in \(itemPath)")
                        try newText.write(toFile: itemPath, atomically: true, encoding: .utf8)
                    }
                }
            }
        }
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
        verbosePrint("🔄 Replacing text in files...")
        verbosePrint("📝 Project name: \(projectNameNoSpace)")
        verbosePrint("📝 Bundle ID (Production): \(bundleIdProduction)")
        verbosePrint("📝 Bundle ID (Staging): \(bundleIdStaging)")
        verbosePrint("📝 Minimum version: \(minimumVersion)")

        // Replace in Project.swift
        if fileManager.fileExists(atPath: "Project.swift") {
            verbosePrint("📄 Updating Project.swift")
            var content = try String(contentsOfFile: "Project.swift", encoding: .utf8)
            content = content.replacingOccurrences(of: CONSTANT_BUNDLE_STAGING, with: bundleIdStaging)
            content = content.replacingOccurrences(of: CONSTANT_BUNDLE_PRODUCTION, with: bundleIdProduction)
            content = content.replacingOccurrences(of: CONSTANT_PROJECT_NAME, with: projectNameNoSpace)
            content = content.replacingOccurrences(of: CONSTANT_MINIMUM_VERSION, with: minimumVersion)
            try content.write(toFile: "Project.swift", atomically: true, encoding: .utf8)
        }

        // Replace in Workspace.swift
        if fileManager.fileExists(atPath: "Workspace.swift") {
            verbosePrint("📄 Updating Workspace.swift")
            var content = try String(contentsOfFile: "Workspace.swift", encoding: .utf8)
            content = content.replacingOccurrences(of: CONSTANT_PROJECT_NAME, with: projectNameNoSpace)
            try content.write(toFile: "Workspace.swift", atomically: true, encoding: .utf8)
        }

        verbosePrint("✅ Text replacement completed")
    }

    private func installTuistIfNeeded() throws {
        let tuistLocation = try safeShell("command -v tuist")
        if let tuistLocation, tuistLocation.isEmpty {
            verbosePrint("Tuist could not be found")
            verbosePrint("Installing tuist")
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

        verbosePrint("🔧 Setting up Tuist configuration...")
        let currentDirectory = fileManager.currentDirectoryPath
        verbosePrint("📂 Current directory: \(currentDirectory)")

        // List directory contents before setup
        if let contents = try? fileManager.contentsOfDirectory(atPath: currentDirectory) {
            verbosePrint("📋 Directory contents before Tuist setup:")
            contents.forEach { verbosePrint("   - \($0)") }
        }

        // Remove existing Project.swift if it exists
        if fileManager.fileExists(atPath: "\(currentDirectory)/Project.swift") {
            verbosePrint("🗑️ Removing existing Project.swift")
            try fileManager.removeItem(atPath: "\(currentDirectory)/Project.swift")
        }

        // Select and copy the appropriate Project.swift file
        switch dependencyManager {
        case .spm:
            verbosePrint("📦 Using Swift Package Manager configuration")
            if fileManager.fileExists(atPath: "\(currentDirectory)/Project.swift.spm") {
                try fileManager.copy(file: "Project.swift.spm", to: "Project.swift")
                if fileManager.fileExists(atPath: "\(currentDirectory)/Project.swift.cocoapods") {
                    try fileManager.removeItem(atPath: "\(currentDirectory)/Project.swift.cocoapods")
                }
                // Remove Workspace.swift and any existing workspace files for SPM
                if fileManager.fileExists(atPath: "\(currentDirectory)/Workspace.swift") {
                    try fileManager.removeItem(atPath: "\(currentDirectory)/Workspace.swift")
                }
                // Remove any existing workspace files
                let workspaceFiles = try fileManager.contentsOfDirectory(atPath: currentDirectory).filter { $0.hasSuffix(".xcworkspace") }
                for workspaceFile in workspaceFiles {
                    try fileManager.removeItem(atPath: "\(currentDirectory)/\(workspaceFile)")
                }
            } else {
                verbosePrint("❌ Error: Project.swift.spm not found")
                throw NSError(domain: "iOSTemplateMaker", code: 1, userInfo: [NSLocalizedDescriptionKey: "Project.swift.spm not found"])
            }
        case .cocoapods:
            verbosePrint("📦 Using CocoaPods configuration")
            if fileManager.fileExists(atPath: "\(currentDirectory)/Project.swift.cocoapods") {
                try fileManager.copy(file: "Project.swift.cocoapods", to: "Project.swift")
                if fileManager.fileExists(atPath: "\(currentDirectory)/Project.swift.spm") {
                    try fileManager.removeItem(atPath: "\(currentDirectory)/Project.swift.spm")
                }
                // Ensure Workspace.swift exists and has correct project name
                if fileManager.fileExists(atPath: "\(currentDirectory)/Workspace.swift") {
                    var workspaceContent = try String(contentsOfFile: "\(currentDirectory)/Workspace.swift", encoding: .utf8)
                    workspaceContent = workspaceContent.replacingOccurrences(of: "{PROJECT_NAME}", with: projectNameNoSpace)
                    try workspaceContent.write(toFile: "\(currentDirectory)/Workspace.swift", atomically: true, encoding: .utf8)
                }
            } else {
                verbosePrint("❌ Error: Project.swift.cocoapods not found")
                throw NSError(domain: "iOSTemplateMaker", code: 1, userInfo: [NSLocalizedDescriptionKey: "Project.swift.cocoapods not found"])
            }
        case .none:
            throw NSError(
                domain: "iOSTemplateMaker",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Dependency manager not selected"]
            )
        }

        // List directory contents after Project.swift setup
        if let contents = try? fileManager.contentsOfDirectory(atPath: currentDirectory) {
            verbosePrint("📋 Directory contents after Project.swift setup:")
            contents.forEach { verbosePrint("   - \($0)") }
        }

        // Run Tuist generate
        verbosePrint("🚀 Running Tuist generate...")
        do {
            let tuistCommand: String
            switch dependencyManager {
            case .spm:
                tuistCommand = "tuist generate --no-open"
            case .cocoapods:
                tuistCommand = "tuist generate"
            case .none:
                throw NSError(
                    domain: "iOSTemplateMaker",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "Dependency manager not selected"]
                )
            }
            let output = try safeShell(tuistCommand)
            verbosePrint("📝 Tuist output: \(output ?? "No output")")
        } catch {
            verbosePrint("❌ Error running Tuist: \(error.localizedDescription)")
            throw error
        }

        // List directory contents after Tuist generation
        if let contents = try? fileManager.contentsOfDirectory(atPath: currentDirectory) {
            verbosePrint("📋 Directory contents after Tuist generation:")
            contents.forEach { verbosePrint("   - \($0)") }
        }

        verbosePrint("✅ Tuist configuration completed")
    }

    private func installDependencies() throws {
        verbosePrint("📦 Installing dependencies...")

        // Always install bundle dependencies first
        try safeShell("bundle install")

        // Run Arkana to generate the ArkanaKeys package
        try safeShell("bundle exec arkana")

        // Install additional dependencies based on dependency manager
        switch dependencyManager {
        case .cocoapods:
            try safeShell("bundle exec pod install --repo-update")
        case .spm, .none:
            verbosePrint("✅ Using Swift Package Manager for dependency management.")
        }

        verbosePrint("✅ Dependencies installed successfully")
    }

    private func makeSPMPackagesString() -> String {
        guard dependencyManager == .spm else { return "" }

        let isUIKit = interface == .uiKit

        // Shared packages between UIKit and SwiftUI
        var packages: [String] = [
            // UI
            #".package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.0.0"),"#,

            // Networking / Backend
            #".package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.6.0"),"#,
            #".package(url: "https://github.com/nimblehq/JSONMapper.git", from: "1.1.1"),"#,

            // Storage
            #".package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.2"),"#,

            // Testing
            #".package(url: "https://github.com/Quick/Quick.git", from: "7.0.0"),"#,
            #".package(url: "https://github.com/Quick/Nimble.git", from: "12.0.0"),"#,
            #".package(url: "https://github.com/krzysztofzablocki/Sourcery.git", from: "2.0.0"),"#,
            #".package(url: "https://github.com/AliSoftware/OHHTTPStubs.git", from: "9.0.0"),"#,

            // Tools
            #".package(url: "https://github.com/nimblehq/NimbleExtension.git", branch: "master"),"#,
            #".package(url: "https://github.com/hmlongco/Factory.git", from: "2.2.0"),"#,
            #".package(url: "https://github.com/realm/SwiftLint.git", from: "0.54.0"),"#,
            #".package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.0.0"),"#,

            // Secrets
            #".package(path: "ArkanaKeys/ArkanaKeys")"#
        ]

        // UIKit-only packages
        if isUIKit {
            packages.insert(#".package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.6.0"),"#, at: 1)
            packages.insert(#".package(url: "https://github.com/hackiftekhar/IQKeyboardManager.git", from: "6.5.10"),"#, at: 5)
            packages.insert(#".package(url: "https://github.com/kif-framework/KIF.git", from: "0.10.0"),"#, at: 8)
        }

        return packages.joined(separator: "\n")
    }

    private func removeGitkeepFromXcodeProject() throws {
        let escapedProjectNameNoSpace = projectNameNoSpace.replacingOccurrences(of: ".", with: "\\.")
        try safeShell("sed -i \"\" \"s/.*\\(gitkeep\\).*,//\" \(escapedProjectNameNoSpace).xcodeproj/project.pbxproj")
    }

    private func removeTemplateFiles() throws {
        let filesToRemove = [
            ".tuist-version",
            "tuist",
            "Project.swift",
            "Project.swift.spm",
            "Project.swift.cocoapods",
            "Workspace.swift",
            ".github/workflows/test_uikit_install_script.yml",
            ".github/workflows/test_swiftui_install_script.yml"
        ]

        for file in filesToRemove {
            if fileManager.fileExists(atPath: file) {
                try fileManager.removeItem(atPath: file)
            }
        }

        if fileManager.fileExists(atPath: ".git/index") {
            try fileManager.removeItem(atPath: ".git/index")
            try safeShell("git reset")
        }
    }

    private func setUpCICD() throws {
        if !isCI {
            try SetUpCICDService().perform()
            try SetUpDeliveryConstants().perform()
            try fileManager.removeItems(in: "Scripts")
        }
    }

    private func openProject() throws {
        guard !isCI else { return }
        
        let fileToOpen: String
        
        switch dependencyManager {
        case .cocoapods:
            fileToOpen = "\(projectNameNoSpace).xcworkspace"
        case .spm:
            fileToOpen = "\(projectNameNoSpace).xcodeproj"
        case .none:
            throw NSError(
                domain: "SetUpIOSProject",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "❌ Cannot open project. No dependency manager was selected."]
            )
        }

        // Print debug information
        verbosePrint("🔍 Looking for project file: \(fileToOpen)")
        verbosePrint("📂 Current directory: \(fileManager.currentDirectoryPath)")

        if fileManager.fileExists(atPath: fileToOpen) {
            verbosePrint("✅ Found project file")
            try safeShell("open -a Xcode \(fileToOpen)")
        } else {
            verbosePrint("❌ Project file not found")
            // List directory contents to help debug
            if let contents = try? fileManager.contentsOfDirectory(atPath: ".") {
                verbosePrint("📋 Directory contents:")
                contents.forEach { verbosePrint("   - \($0)") }
            }
            throw NSError(
                domain: "SetUpIOSProject",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "❌ Project file not found: \(fileToOpen)"]
            )
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
