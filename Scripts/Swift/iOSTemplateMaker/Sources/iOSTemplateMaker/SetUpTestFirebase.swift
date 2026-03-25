import Foundation

struct SetUpTestFirebase {

    private let teamIdPlaceholder = "<#teamId#>"
    private let devFirebaseAppIdPlaceholder = "<#devFirebaseAppId#>"
    private let stagingFirebaseAppIdPlaceholder = "<#stagingFirebaseAppId#>"
    private let firebaseTesterGroupsPlaceholder = "<#group1#>, <#group2#>"
    private let matchRepoPlaceholder = "git@github.com:{organization}/{repo}.git"

    private let firebaseTesterGroup = "nimble"
    private let fileManager = FileManager.default
    private let devFirebaseAppId: String = "1:394751167018:ios:bc6ca71168a46096b21153"
    private let stagingFirebaseAppId: String = "1:394751167018:ios:7670aacd2a018cd5b21153"

    let matchRepo: String
    let teamId: String

    func perform() {
        fileManager.replaceAllOccurrences(of: teamIdPlaceholder, to: teamId)
        fileManager.replaceAllOccurrences(of: devFirebaseAppIdPlaceholder, to: devFirebaseAppId)
        fileManager.replaceAllOccurrences(of: stagingFirebaseAppIdPlaceholder, to: stagingFirebaseAppId)
        fileManager.replaceAllOccurrences(of: firebaseTesterGroupsPlaceholder, to: firebaseTesterGroup)
        fileManager.replaceAllOccurrences(of: matchRepoPlaceholder, to: matchRepo)
    }
}
