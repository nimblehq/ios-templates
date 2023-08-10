let teamIdPlaceholder = "<#teamId#>"
let apiKeyIdPlaceholder = "<#API_KEY_ID#>"
let issuerIdPlaceholder = "<#ISSUER_ID#>"
let matchRepoPlaceholder = "git@github.com:{organization}/{repo}.git"

let envMatchRepo = ProcessInfo.processInfo.environment["MATCH_REPO"] ?? ""
let envApiKey = ProcessInfo.processInfo.environment["API_KEY_ID"] ?? ""
let envIssuerId = ProcessInfo.processInfo.environment["ISSUER_ID"] ?? ""
let envTeamId = ProcessInfo.processInfo.environment["TEAM_ID"] ?? ""

let fileManager = FileManager.default

fileManager.replaceAllOccurrences(of: teamIdPlaceholder, to: envTeamId)
fileManager.replaceAllOccurrences(of: apiKeyIdPlaceholder, to: envApiKey)
fileManager.replaceAllOccurrences(of: issuerIdPlaceholder, to: envIssuerId)
fileManager.replaceAllOccurrences(of: matchRepoPlaceholder, to: envMatchRepo)
