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

    func syncDevelopmentCodeSigningLane() {
        desc("Sync the Development match signing for the Staging build")
        Match.syncCodeSigning(
            type: .development,
            appIdentifier: [Constant.stagingBundleId]
        )
    }

    func syncAdHocStagingCodeSigningLane() {
        desc("Sync the Ad Hoc match signing for the Staging build")
        Match.syncCodeSigning(
            type: .adHoc,
            appIdentifier: [Constant.stagingBundleId]
        )
    }

    func syncAdHocProductionCodeSigningLane() {
        desc("Sync the Ad Hoc match signing for the Production build")
        Match.syncCodeSigning(
            type: .adHoc,
            appIdentifier: [Constant.productionBundleId]
        )
    }

    func syncAppStoreCodeSigningLane() {
        desc("Sync the App Store match signing for the Production build")
        Match.syncCodeSigning(
            type: .appStore,
            appIdentifier: [Constant.productionBundleId]
        )
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

    // MARK: - Upload to Firebase

    func buildStagingAndUploadToFirebaseLane() {
        desc("Build Staging app and upload to Firebase")

        setAppVersion()
        bumpBuild()

        buildAdHocStagingLane()
        Symbol.uploadAdhocToCrashlytics(environment: .staging)
        // TODO: - Make release notes
        Distribution.uploadToFirebase(environment: .staging, releaseNotes: "")
    }

    func buildProductionAndUploadToFirebaseLane() {
        desc("Build Staging app and upload to Firebase")

        setAppVersion()
        bumpBuild()

        buildAdHocProductionLane()
        Symbol.uploadAdhocToCrashlytics(environment: .production)
        // TODO: - Make release notes
        Distribution.uploadToFirebase(environment: .production, releaseNotes: "")
    }

    func buildAndUploadToAppStoreLane() {
        desc("Build Production app and upload to App Store")

        setAppVersion()
        bumpBuild()

        buildAppStoreLane()
        AppStoreAuthentication.connectAPIKey()
        Distribution.uploadToAppStore()
        // TODO: - Use our Version helpers instead
        let versionNumber = getVersionNumber()
        let buildNumber = getBuildNumber()
        Symbol.downloadFromAppStore(versionNumber: versionNumber, buildNumber: buildNumber)
        Symbol.uploadAppStoreToCrashlytics(versionNumber: versionNumber, buildNumber: buildNumber)
    }

    func buildAndUploadToTestFlightLane() {
        desc("Build Production app and upload to TestFlight")

        buildAppStoreLane()
        AppStoreAuthentication.connectAPIKey()
        Distribution.uploadToTestFlight()
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
}
