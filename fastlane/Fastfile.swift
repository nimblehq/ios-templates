// This file contains the fastlane.tools configuration
// You can find the documentation at https://docs.fastlane.tools
//
// For a list of all available actions, check out
//
//     https://docs.fastlane.tools/actions
//

import Foundation

class Fastfile: LaneFile {

    func syncCodeSigningLane() {
        desc("This lane is for development purpose, will be removed after the migration")
        Match.syncCodeSigning(type: .development, appIdentifier: ["co.nimblehq.ios.templates"])
        Match.syncCodeSigning(type: .adHoc, appIdentifier: ["co.nimblehq.ios.templates"])
        Match.syncCodeSigning(type: .appStore, appIdentifier: ["co.nimblehq.ios.templates"])
    }
}
