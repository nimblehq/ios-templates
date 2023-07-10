static let ConstantTeamId = "<#teamId#>"
static let ConstantStagingFirebaseAppId = "<#stagingFirebaseAppId#>"
static let ConstantFirebaseTesterGroups = "<#group1#>, <#group2#>"
static let ConstantMatchRepo = "git@github.com:{organization}\/{repo}.git"

let envMatchRepo = ProcessInfo.processInfo.environment["MATCH_REPO"]
let envStagingFirebaseAppId = ProcessInfo.processInfo.environment["STAGING_FIREBASE_APP_ID"]
let envTeamId = ProcessInfo.processInfo.environment["TEAM_ID"]
let matchRepoEscaped = envMatchRepo.replacingOccurrences(of: "/", with: "\/")
let firebaseTesterGroup = "nimble"

let fileManager = FileManager.default
let workingDirectory = fileManager.currentDirectoryPath

try? safeShell("LC_ALL=C find \(workingDirectory) -type f -exec sed -i \"\" \"s/\(ConstantTeamId)/\(envTeamId)/g\" {} +")
try? safeShell("LC_ALL=C find \(workingDirectory) -type f -exec sed -i \"\" \"s/\(ConstantStagingFirebaseAppId)/\(envStagingFirebaseAppId)/g\" {} +")
try? safeShell("LC_ALL=C find \(workingDirectory) -type f -exec sed -i \"\" \"s/\(ConstantFirebaseTesterGroups)/\(firebaseTesterGroup)/g\" {} +")
try? safeShell("LC_ALL=C find \(workingDirectory) -type f -exec sed -i \"\" \"s/\(ConstantMatchRepo)/\(matchRepoEscaped)/g\" {} +")
