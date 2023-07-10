let ConstantTeamId = "<#teamId#>"
let ConstantStagingFirebaseAppId = "<#stagingFirebaseAppId#>"
let ConstantFirebaseTesterGroups = "<#group1#>, <#group2#>"
let ConstantMatchRepo = "git@github.com:{organization}\\/{repo}.git"

let envMatchRepo = ProcessInfo.processInfo.environment["MATCH_REPO"] ?? ""
let envStagingFirebaseAppId = ProcessInfo.processInfo.environment["STAGING_FIREBASE_APP_ID"] ?? ""
let envTeamId = ProcessInfo.processInfo.environment["TEAM_ID"] ?? ""
let matchRepoEscaped = envMatchRepo.replacingOccurrences(of: "/", with: "\\/")
let firebaseTesterGroup = "nimble"

let fileManager = FileManager.default

try fileManager.replaceAllOccurrences(of: ConstantTeamId, to: envTeamId)
try fileManager.replaceAllOccurrences(of: ConstantStagingFirebaseAppId, to: envStagingFirebaseAppId)
try fileManager.replaceAllOccurrences(of: ConstantFirebaseTesterGroups, to: firebaseTesterGroup)
try fileManager.replaceAllOccurrences(of: ConstantMatchRepo, to: matchRepoEscaped)
