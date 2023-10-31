import Foundation

struct SetUpTestTestFlight {

    private let teamIdPlaceholder = "<#teamId#>"
    private let apiKeyIdPlaceholder = "<#API_KEY_ID#>"
    private let issuerIdPlaceholder = "<#ISSUER_ID#>"
    private let matchRepoPlaceholder = "git@github.com:{organization}/{repo}.git"

    private let fileManager = FileManager.default

    let matchRepo: String
    let apiKey: String
    let issuerId: String
    let teamId: String

    func perform() {
        fileManager.replaceAllOccurrences(of: teamIdPlaceholder, to: teamId)
        fileManager.replaceAllOccurrences(of: apiKeyIdPlaceholder, to: apiKey)
        fileManager.replaceAllOccurrences(of: issuerIdPlaceholder, to: issuerId)
        fileManager.replaceAllOccurrences(of: matchRepoPlaceholder, to: matchRepo)
    }
}
