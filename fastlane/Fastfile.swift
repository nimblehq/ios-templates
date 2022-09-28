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

        buildAdHocStagingLane()
        Symbol.uploadToCrashlytics(environment: .staging)
        // TODO: - Make release notes
        Distribution.uploadToFirebase(environment: .staging, releaseNotes: "")
    }

    func buildProductionAndUploadToFirebaseLane() {
        desc("Build Staging app and upload to Firebase")

        buildAdHocProductionLane()
        Symbol.uploadToCrashlytics(environment: .production)
        // TODO: - Make release notes
        Distribution.uploadToFirebase(environment: .production, releaseNotes: "")
    }

    func buildAndUploadToAppStoreLane() {
        desc("Build Production app and upload to App Store")

        buildAppStoreLane()
        AppStoreAuthentication.connectAPIKey()
        Distribution.uploadToAppStore()
    }
}
