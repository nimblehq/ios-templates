#!/usr/bin/swift

let CONSTANT_PROJECT_NAME = "TemplateApp"
let CONSTANT_BUNDLE_PRODUCTION = "co.nimblehq.ios.templates"
let CONSTANT_BUNDLE_STAGING = "co.nimblehq.ios.templates.staging"
let CONSTANT_MINIMUM_VERSION = ""

var bundleIdProduction = ""
var bundleIdStaging = ""
var projectName = ""
var minimumVersion = ""
var interface: SetUpInterface.Interface?

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

// Select the Interface
SetUpInterface().perform(interface ?? .uiKit, projectName)

print("=> 🐢 Starting init \(projectName) ...")


/*
# Rename files structure
echo "=> 🔎 Replacing files structure..."


## user define function
rename_folder(){
    local DIR=$1
    local NEW_DIR=$2
    if [ -d "$DIR" ]
    then
        mv ${DIR} ${NEW_DIR}
    fi
}

# Rename test folder structure
rename_folder "${CONSTANT_PROJECT_NAME}Tests" "${PROJECT_NAME_NO_SPACES}Tests"

# Rename KIF UI Test folder structure
rename_folder "${CONSTANT_PROJECT_NAME}KIFUITests" "${PROJECT_NAME_NO_SPACES}KIFUITests"

# Rename app folder structure
rename_folder "${CONSTANT_PROJECT_NAME}" "${PROJECT_NAME_NO_SPACES}"

# Duplicate the env example file and rename it to env file
cp "./.env.example" "./.env"

# Add AutoMockable.generated.swift file
mkdir -p "${PROJECT_NAME_NO_SPACES}Tests/Sources/Mocks/Sourcery"
touch "${PROJECT_NAME_NO_SPACES}Tests/Sources/Mocks/Sourcery/AutoMockable.generated.swift"

# Add R.generated.swift file
mkdir -p "${PROJECT_NAME_NO_SPACES}/Sources/Supports/Helpers/Rswift"
touch "${PROJECT_NAME_NO_SPACES}/Sources/Supports/Helpers/Rswift/R.generated.swift"

echo "✅  Completed"

# Search and replace in files
echo "=> 🔎 Replacing package and package name within files..."
BUNDLE_ID_PRODUCTION_ESCAPED="${bundle_id_production//./\.}"
BUNDLE_ID_STAGING_ESCAPED="${bundle_id_staging//./\.}"
LC_ALL=C find $WORKING_DIR -type f -exec sed -i "" "s/$CONSTANT_BUNDLE_STAGING/$BUNDLE_ID_STAGING_ESCAPED/g" {} +
LC_ALL=C find $WORKING_DIR -type f -exec sed -i "" "s/$CONSTANT_BUNDLE_PRODUCTION/$BUNDLE_ID_PRODUCTION_ESCAPED/g" {} +
LC_ALL=C find $WORKING_DIR -type f -exec sed -i "" "s/$CONSTANT_PROJECT_NAME/$PROJECT_NAME_NO_SPACES/g" {} +
LC_ALL=C find $WORKING_DIR -type f -exec sed -i "" "s/$CONSTANT_MINIMUM_VERSION/$minimum_version/g" {} +
echo "✅  Completed"

# check for tuist and install
if ! command -v tuist &> /dev/null
then
    echo "Tuist could not be found"
    echo "Installing tuist"
    readonly TUIST_VERSION=`cat .tuist-version`
    curl -Ls https://install.tuist.io | bash
    tuist install ${TUIST_VERSION}
fi

# Generate with tuist
echo "Tuist found"
tuist generate --no-open
echo "✅  Completed"

# Install dependencies
echo "Installing gems"
bundle install

echo "Run Arkana"
bundle exec arkana

echo "Installing pod dependencies"
bundle exec pod install --repo-update
echo "✅  Completed"

# Remove gitkeep files
echo "Remove gitkeep files from project"
sed -i "" "s/.*\(gitkeep\).*,//" $PROJECT_NAME_NO_SPACES.xcodeproj/project.pbxproj
echo "✅  Completed"

# Remove Tuist files
echo "Remove tuist files"
rm -rf .tuist-version
rm -rf tuist
rm -rf Project.swift
rm -rf Workspace.swift

# Remove script files and git/index
echo "Remove script files and git/index"
rm -rf make.sh
rm -rf .github/workflows/test_install_script.yml
rm -f .git/index
git reset

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
