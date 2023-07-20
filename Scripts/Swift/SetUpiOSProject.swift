#!/usr/bin/swift

let CONSTANT_PROJECT_NAME = "{PROJECT_NAME}"
let CONSTANT_BUNDLE_PRODUCTION = "{BUNDLE_ID_PRODUCTION}"
let CONSTANT_BUNDLE_STAGING = "{BUNDLE_ID_STAGING}"
let CONSTANT_MINIMUM_VERSION = "{TARGET_VERSION}"

var bundleIdProduction = ""
var bundleIdStaging = ""
var projectName = ""
var minimumVersion = ""
var interface: SetUpInterface.Interface?

var isCI = !(ProcessInfo.processInfo.environment["CI"] ?? "").isEmpty

// TODO: Should be replaced with ArgumentParser instead of command line
for (index, argument) in CommandLine.arguments.enumerated() {
    switch index {
    case 1: bundleIdProduction = argument
    case 2: bundleIdStaging = argument
    case 3: projectName = argument
    case 4: minimumVersion = argument
    case 5: interface = .init(argument)
    default: break
    }
}

if isCI {
    minimumVersion = "14.0"
}

func checkPackageName(_ name: String) -> Bool {
    let packageNameRegex="^[a-z][a-z0-9_]*(\\.[a-z0-9_-]+)+[0-9a-z_-]$"
    let valid = name ~= packageNameRegex
    if !valid {
        print("Please pick a valid package name with pattern {com.example.package}")
    }
    return valid
}

func checkVersion(_ version: String) -> Bool {
    let versionRegex="^[0-9_]+(\\.[0-9]+)+$"
    let valid = version ~= versionRegex
    if !valid {
        print("Please pick a valid version with pattern {x.y}")
    }
    return valid
}

while bundleIdProduction.isEmpty || !checkPackageName(bundleIdProduction) {
    print("BUNDLE ID PRODUCTION (i.e. com.example.project):")
    bundleIdProduction = readLine() ?? ""
}
while bundleIdStaging.isEmpty || !checkPackageName(bundleIdStaging)  {
    print("BUNDLE ID STAGING (i.e. com.example.project.staging):")
    bundleIdStaging = readLine() ?? ""
}
while projectName.isEmpty {
    print("PROJECT NAME (i.e. NewProject):")
    projectName = readLine() ?? ""
}
while minimumVersion.isEmpty || !checkVersion(minimumVersion) {
    print("iOS Minimum Version (i.e. 14.0):")
    minimumVersion = readLine() ?? "14.0"
}
while interface == nil {
    print("Interface [(S)wiftUI or (U)IKit]:")
    interface = SetUpInterface.Interface(readLine() ?? "")
}
let projectNameNoSpace = projectName.trimmingCharacters(in: .whitespacesAndNewlines)

print("=> 🐢 Starting init \(projectName) ...")

print("=> 🔎 Replacing files structure...")

let fileManager = FileManager.default

// Rename test folder structure
fileManager.rename(file: "\(CONSTANT_PROJECT_NAME)Tests", to: "\(projectNameNoSpace)Tests")

// Rename KIF UI Test folder structure
fileManager.rename(file: "\(CONSTANT_PROJECT_NAME)KIFUITests", to: "\(projectNameNoSpace)KIFUITests")

// Rename app folder structure
fileManager.rename(file: "\(CONSTANT_PROJECT_NAME)", to: "\(projectNameNoSpace)")

// Duplicate the env example file to env file
fileManager.copy(file: ".env.example", to: ".env")

// Add AutoMockable.generated.swift file
fileManager.createFile(name: "AutoMockable.generated.swift", at: "\(projectNameNoSpace)Tests/Sources/Mocks/Sourcery")

// Add AutoMockable.generated.swift file
fileManager.createFile(name: "R.generated.swift", at: "\(projectNameNoSpace)/Sources/Supports/Helpers/Rswift")

// Select the Interface
SetUpInterface().perform(interface ?? .uiKit, projectName)

print("✅  Completed")

// Search and replace in files

print("=> 🔎 Replacing package and package name within files...")

try fileManager.replaceAllOccurrences(of: CONSTANT_BUNDLE_STAGING, to: bundleIdStaging)
try fileManager.replaceAllOccurrences(of: CONSTANT_BUNDLE_PRODUCTION, to: bundleIdProduction)
try fileManager.replaceAllOccurrences(of: CONSTANT_PROJECT_NAME, to: projectNameNoSpace)
try fileManager.replaceAllOccurrences(of: CONSTANT_MINIMUM_VERSION, to: minimumVersion)
print("✅  Completed")

// check for tuist and install
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

// Generate with tuist
try safeShell("tuist generate --no-open")
print("✅  Completed")

// Install dependencies
print("Installing gems")
try safeShell("bundle install")

// Install dependencies
print("Run Arkana")
try safeShell("bundle exec arkana")

print("Installing pod dependencies")
try safeShell("bundle exec pod install --repo-update")
print("✅  Completed")

// Remove gitkeep files
print("Remove gitkeep files from project")
let escapedProjectNameNoSpace = projectNameNoSpace.replacingOccurrences(of: ".", with: "\\.")
try safeShell("sed -i \"\" \"s/.*\\(gitkeep\\).*,//\" \(escapedProjectNameNoSpace).xcodeproj/project.pbxproj")
print("✅  Complete")

// Remove Tuist files
print("Remove tuist files")
fileManager.removeItems(in: ".tuist-version")
fileManager.removeItems(in: "tuist")
fileManager.removeItems(in: "Project.swift")
fileManager.removeItems(in: "Workspace.swift")

// Remove script files and git/index
print("Remove script files and git/index")
fileManager.removeItems(in: "make.sh")
fileManager.removeItems(in: ".github/workflows/test_install_script.yml")
fileManager.removeItems(in: ".git/index")
try safeShell("git reset")

/*

if [[ -z "${CI}" ]]; then
    rm -rf fastlane/Tests
    rm -f set_up_test_testflight.sh
    cat Scripts/Swift/SetUpCICDService.swift Scripts/Swift/Extensions/FileManager+Utils.swift Scripts/Swift/Helpers/SafeShell.swift > t.swift && swift t.swift && rm -rf 't.swift'
    cat Scripts/Swift/SetUpDeliveryConstants.swift Scripts/Swift/Extensions/FileManager+Utils.swift Scripts/Swift/Helpers/SafeShell.swift > t.swift && swift t.swift && rm -rf 't.swift'
    rm -rf Scripts
fi


echo "✅  Completed"

# Done!
echo "=> 🚀 Done! App is ready to be tested 🙌"

if [[ -z "${CI}" ]]; then
    echo "=> 🛠 Opening the project."
    open -a Xcode $PROJECT_NAME_NO_SPACES.xcworkspace
fi
*/
