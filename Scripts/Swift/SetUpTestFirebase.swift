let teamIdPlaceholder = "<#teamId#>"
let stagingFirebaseAppIdPlaceholder = "<#stagingFirebaseAppId#>"
let firebaseTesterGroupsPlaceholder = "<#group1#>, <#group2#>"
let matchRepoPlaceholder = "git@github.com:{organization}/{repo}.git"

let envMatchRepo = ProcessInfo.processInfo.environment["MATCH_REPO"] ?? ""
let envStagingFirebaseAppId = ProcessInfo.processInfo.environment["STAGING_FIREBASE_APP_ID"] ?? ""
let envTeamId = ProcessInfo.processInfo.environment["TEAM_ID"] ?? ""
let firebaseTesterGroup = "nimble"

let fileManager = FileManager.default

fileManager.replaceAllOccurrences(of: teamIdPlaceholder, to: envTeamId)
fileManager.replaceAllOccurrences(of: stagingFirebaseAppIdPlaceholder, to: envStagingFirebaseAppId)
fileManager.replaceAllOccurrences(of: firebaseTesterGroupsPlaceholder, to: firebaseTesterGroup)
fileManager.replaceAllOccurrences(of: matchRepoPlaceholder, to: envMatchRepo)
