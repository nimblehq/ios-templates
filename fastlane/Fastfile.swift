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
}
