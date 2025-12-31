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
    private var projectNameNoSpace: String { projectName.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var isCI = !((EnvironmentValue.value(for: .isCI)).string).isEmpty

    init(
        bundleIdProduction: String = "",
        bundleIdStaging: String = "",
        projectName: String = "",
        minimumVersion: String = ""
    ) {
        self.bundleIdProduction = bundleIdProduction
        self.bundleIdStaging = bundleIdStaging
        self.projectName = projectName
        self.minimumVersion = minimumVersion
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
                try SetUpInterface().perform(.swiftUI, projectName)
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
        fileManager.replaceAllOccurrences(of: CONSTANT_BUNDLE_STAGING, to: bundleIdStaging)
        fileManager.replaceAllOccurrences(of: CONSTANT_BUNDLE_PRODUCTION, to: bundleIdProduction)
        fileManager.replaceAllOccurrences(of: CONSTANT_PROJECT_NAME, to: projectNameNoSpace)
        fileManager.replaceAllOccurrences(of: CONSTANT_MINIMUM_VERSION, to: minimumVersion)
    }

    private func installTuistIfNeeded() throws {
        print("🔍 Checking if Tuist is installed...")
        let tuistLocation = try safeShell("command -v tuist")
        if let tuistLocation, tuistLocation.isEmpty {
            print("⚠️ Tuist could not be found")
            print("💡 Tip: Install Tuist using Mise: mise install")
            print("📦 Attempting to install Tuist...")
            
            // Read version from .mise.toml (preferred) or fallback to .tuist-version
            let tuistVersion = readTuistVersion()
            print("📌 Installing Tuist version: \(tuistVersion)")
            
            if tuistVersion != "unknown" {
                try safeShell(
                    """
                        readonly TUIST_VERSION="\(tuistVersion)"
                        curl -Ls https://install.tuist.io | bash
                        tuist install ${TUIST_VERSION}
                    """
                )
                
                // Verify installation
                if let version = try? safeShell("tuist version") {
                    print("✅ Tuist installed. Version: \(version.trimmingCharacters(in: .whitespacesAndNewlines))")
                }
            } else {
                print("❌ Could not determine Tuist version. Please install manually or use Mise.")
            }
        } else {
            print("✅ Tuist found at: \(tuistLocation ?? "unknown")")
            if let version = try? safeShell("tuist version") {
                print("📌 Tuist version: \(version.trimmingCharacters(in: .whitespacesAndNewlines))")
            }
        }
    }
    
    private func readTuistVersion() -> String {
        // Try reading from .mise.toml first (preferred)
        if let miseTomlContent = try? String(contentsOfFile: ".mise.toml", encoding: .utf8) {
            // Simple parsing: look for tuist = "version" pattern
            let lines = miseTomlContent.components(separatedBy: .newlines)
            for line in lines {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if trimmed.hasPrefix("tuist") && trimmed.contains("=") {
                    // Extract version from tuist = "4.110.3" or tuist="4.110.3"
                    // Find the quoted version string
                    if let quoteStart = trimmed.firstIndex(of: "\""),
                       let quoteEnd = trimmed[quoteStart...].dropFirst().firstIndex(of: "\"") {
                        let versionStart = trimmed.index(after: quoteStart)
                        let version = String(trimmed[versionStart..<quoteEnd])
                        return version
                    }
                }
            }
        }
        
        // Fallback to .tuist-version for backward compatibility
        if let tuistVersionContent = try? String(contentsOfFile: ".tuist-version", encoding: .utf8) {
            return tuistVersionContent.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        return "unknown"
    }

    private func runTuist() throws {
        try installTuistIfNeeded()
        
        print("🚀 Generating project with Tuist...")
        print("📋 Project name: \(projectNameNoSpace)")
        
        // Check files before generation
        let projectSwiftExists = fileManager.fileExists(atPath: "Project.swift")
        let tuistHelpersExists = fileManager.fileExists(atPath: "Tuist/ProjectDescriptionHelpers")
        print("🔍 Pre-generation check:")
        print("   Project.swift exists: \(projectSwiftExists)")
        print("   Tuist/ProjectDescriptionHelpers exists: \(tuistHelpersExists)")
        
        // Clean Tuist cache if it exists (might help with compilation issues)
        print("🧹 Cleaning Tuist cache...")
        let _ = try? safeShell("tuist clean")
        
        // List ProjectDescriptionHelpers files for debugging
        if tuistHelpersExists {
            print("📁 ProjectDescriptionHelpers files:")
            if let helpersFiles = try? fileManager.contentsOfDirectory(atPath: "Tuist/ProjectDescriptionHelpers") {
                for file in helpersFiles.sorted() {
                    print("   - \(file)")
                }
            }
        }
        
        // Run Tuist generate with verbose output
        print("⚙️ Running: tuist generate --no-open")
        let output = try safeShell("tuist generate --no-open")
        if let output = output, !output.isEmpty {
            print("📤 Tuist output:")
            print(output)
        }
        
        // Verify files after generation
        let projectFile = "\(projectNameNoSpace).xcodeproj"
        
        print("🔍 Post-generation verification:")
        let projectExists = fileManager.fileExists(atPath: projectFile)
        print("   \(projectFile) exists: \(projectExists)")
        
        // Note: Using Xcode's native SPM integration via packages defined in Project.swift.
        // This integrates packages directly into the project without generating a workspace.
        // Packages will appear in Xcode's "Package Dependencies" section.
        //
        // Sources:
        // - https://docs.tuist.dev/en/guides/develop/projects/dependencies
        
        if !projectExists {
            print("❌ ERROR: Project file was not generated!")
            print("💡 Check Tuist logs for more details:")
            print("   ~/.local/state/tuist/logs/")
            print("💡 Try running manually: tuist generate --verbose")
        } else {
            print("✅ Tuist generation completed successfully!")
            print("   Open \(projectFile) in Xcode to see SPM dependencies in Package Dependencies.")
        }
    }

    private func installDependencies() throws {
        try safeShell("bundle install")
        try safeShell("bundle exec arkana")
        // SPM dependencies are resolved automatically by Xcode, no manual installation needed
    }

    private func removeGitkeepFromXcodeProject() throws {
        let escapedProjectNameNoSpace = projectNameNoSpace.replacingOccurrences(of: ".", with: "\\.")
        try safeShell("sed -i \"\" \"s/.*\\(gitkeep\\).*,//\" \(escapedProjectNameNoSpace).xcodeproj/project.pbxproj")
    }

    private func removeTemplateFiles() throws {
        // Note: .mise.toml is kept as it's the source of truth for tool versions
        // .tuist-version is removed if it exists (for backward compatibility cleanup)
        try fileManager.removeItems(in: ".tuist-version")
        try fileManager.removeItems(in: "tuist")
        try fileManager.removeItems(in: "Project.swift")
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
