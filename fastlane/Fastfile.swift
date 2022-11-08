// This file contains the fastlane.tools configuration
// You can find the documentation at https://docs.fastlane.tools
//
// For a list of all available actions, check out
//
//     https://docs.fastlane.tools/actions
//

import Foundation

class Fastfile: LaneFile {

    // MARK: - Code signing

    func syncCodeSigningLane() {
        desc("This lane is for development purpose, will be removed after the migration")
        Match.syncCodeSigning(type: .development, appIdentifier: ["co.nimblehq.ios.templates"])
        Match.syncCodeSigning(type: .adHoc, appIdentifier: ["co.nimblehq.ios.templates"])
        Match.syncCodeSigning(type: .appStore, appIdentifier: ["co.nimblehq.ios.templates"])
    }

    // MARK: - Build

    func buildAdHocStagingLane() {
        desc("Build ad-hoc staging")
        Build.adHoc(environment: .staging)
    }

    func buildAdHocProductionLane() {
        desc("Build ad-hoc production")
        Build.adHoc(environment: .production)
    }

    func buildAppStoreLane() {
        desc("Build app store")
        Build.appStore()
    }

    // MARK: - Upload builds to Firebase and AppStore

    func buildStagingAndUploadToFirebaseLane() {
        desc("Build Staging app and upload to Firebase")

        setAppVersion()
        bumpBuild()

        buildAdHocStagingLane()

        // TODO: - Make release notes
        Distribution.uploadToFirebase(environment: .staging, releaseNotes: "")

        Symbol.uploadToCrashlytics(environment: .staging)
    }

    func buildProductionAndUploadToFirebaseLane() {
        desc("Build Staging app and upload to Firebase")

        setAppVersion()
        bumpBuild()

        buildAdHocProductionLane()

        // TODO: - Make release notes
        Distribution.uploadToFirebase(environment: .production, releaseNotes: "")

        Symbol.uploadToCrashlytics(environment: .production)
    }

    func buildAndUploadToAppStoreLane() {
        desc("Build Production app and upload to App Store")

        setAppVersion()
        bumpBuild()

        buildAppStoreLane()

        AppStoreAuthentication.connectAPIKey()
        Distribution.uploadToAppStore()

        Symbol.uploadToCrashlytics(environment: .production)
    }

    func buildAndUploadToTestFlightLane() {
        desc("Build Production app and upload to TestFlight")

        setAppVersion()
        bumpBuild()

        buildAppStoreLane()

        AppStoreAuthentication.connectAPIKey()
        Distribution.uploadToTestFlight()

        Symbol.uploadToCrashlytics(environment: .production)
    }


    // MARK: - Test

    func buildAndTestLane() {
        desc("Build and Test project")
        Test.buildAndTest(
            environment: .staging,
            targets: [Constant.testTarget, Constant.uiTestTarget],
            devices: Constant.devices
        )
    }

    // MARK: - Register device

    func registerNewDeviceLane() {
        let deviceName = prompt(text: "Enter the device name:")
        let deviceUDID = prompt(text: "Enter the device UDID:")

        registerDevice(
            name: deviceName,
            udid: deviceUDID,
            teamId: .userDefined(Constant.teamId)
        )

        Match.syncCodeSigning(type: .development, appIdentifier: [], isForce: true)
        Match.syncCodeSigning(type: .adHoc, appIdentifier: [], isForce: true)
    }

    // MARK: - Utilities

    func cleanUpOutputLane() {
        desc("Clean up Output")
        clearDerivedData(derivedDataPath: Constant.outputPath)
    }

    // MARK: - Private Helper

    private func setAppVersion() {
        desc("Check if any specific version number in build environment")
        guard !Constant.manualVersion.isEmpty else { return }
        incrementVersionNumber(
            versionNumber: .userDefined(Constant.manualVersion)
        )
    }

    private func bumpBuild(buildNumber: Int = numberOfCommits()) {
        desc("Set build number with number of commits")
        incrementBuildNumber(
            buildNumber: .userDefined(String(buildNumber)),
            xcodeproj: .userDefined(Constant.projectPath))
    }
}
