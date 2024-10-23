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

    func syncDevelopmentStagingCodeSigningLane() {
        desc("Sync the Development match signing for the Staging build")
        Match.syncCodeSigning(
            type: .development,
            environment: .staging
        )
    }

    func syncDevelopmentProductionCodeSigningLane() {
        desc("Sync the Development match signing for the Production build")
        Match.syncCodeSigning(
            type: .development,
            environment: .production
        )
    }

    func syncAdHocStagingCodeSigningLane() {
        desc("Sync the Ad Hoc match signing for the Staging build")
        Match.syncCodeSigning(
            type: .adHoc,
            environment: .staging
        )
    }

    func syncAdHocProductionCodeSigningLane() {
        desc("Sync the Ad Hoc match signing for the Production build")
        Match.syncCodeSigning(
            type: .adHoc,
            environment: .production
        )
    }

    func syncAppStoreCodeSigningLane() {
        desc("Sync the App Store match signing for the Production build")
        Match.syncCodeSigning(
            type: .appStore,
            environment: .production
        )
    }

    func removeKeychainLane() {
        desc("Delete keychain")
        Keychain.remove()
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

        Build.saveBuildContextToCI()
    }

    func buildProductionAndUploadToFirebaseLane() {
        desc("Build Production app and upload to Firebase")

        setAppVersion()
        bumpBuild()

        buildAdHocProductionLane()

        // TODO: - Make release notes
        Distribution.uploadToFirebase(environment: .production, releaseNotes: "")

        Symbol.uploadToCrashlytics(environment: .production)

        Build.saveBuildContextToCI()
    }

    func buildAndUploadToAppStoreLane() {
        desc("Build Production app and upload to App Store")

        setAppVersion()
        AppStoreAuthentication.connectAPIKey()
        if Secret.bumpAppStoreBuildNumber {
            bumpAppstoreBuild()
        } else {
            bumpBuild()
        }

        buildAppStoreLane()

        Distribution.uploadToAppStore()

        Symbol.uploadToCrashlytics(environment: .production)

        Build.saveBuildContextToCI()
    }

    func buildAndUploadToTestFlightLane() {
        desc("Build Production app and upload to TestFlight")

        setAppVersion()
        bumpBuild()

        buildAppStoreLane()

        AppStoreAuthentication.connectAPIKey()
        Distribution.uploadToTestFlight()

        Symbol.uploadToCrashlytics(environment: .production)

        Build.saveBuildContextToCI()
    }

    // MARK: - Test

    func buildAndTestLane() {
        desc("Build and Test project")
        Test.buildAndTest(
            environment: .staging,
            devices: Constant.devices
        )
    }

    func setUpTestProjectLane() {
        desc("Disable Exempt Encryption")
        Test.disableExemptEncryption()
    }

    // MARK: - Register device

    func registerNewDeviceLane() {
        let deviceName = prompt(text: "Enter the device name:")
        let deviceUDID = prompt(text: "Enter the device UDID:")

        registerDevice(
            name: deviceName,
            udid: deviceUDID,
            apiKey: .userDefined(Constant.apiKey),
            teamId: .userDefined(Constant.appleStagingTeamId)
        )

        Match.syncCodeSigning(type: .development, environment: .staging, isForce: true)
        Match.syncCodeSigning(type: .adHoc, environment: .staging, isForce: true)
    }

    func addDevicesGenerateProfilesLane() {
        desc("Add device and regenerate profiles with match")

        guard let data = Secret.devices.data(using: .utf8),
              let devices = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            return
        }
        registerDevices(
            devices: .userDefined(devices),
            apiKey: .userDefined(Constant.apiKey),
            teamId: .userDefined(Constant.appleStagingTeamId),
            platform: Secret.platform
        )

        Match.syncCodeSigning(type: .development, environment: .staging, isForce: true)
        Match.syncCodeSigning(type: .adHoc, environment: .staging, isForce: true)
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
            xcodeproj: .userDefined(Constant.projectPath)
        )
    }

    private func bumpAppstoreBuild() {
        desc("Set build number with App Store latest build")
        let theLatestBuildNumber = latestTestflightBuildNumber(
            appIdentifier: Constant.productionBundleId
        ) + 1
        incrementBuildNumber(
            buildNumber: .userDefined("\(theLatestBuildNumber)")
        )
    }
}
