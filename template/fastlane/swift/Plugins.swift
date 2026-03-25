import Foundation
/**
 Release your beta builds with Firebase App Distribution

 - parameters:
   - ipaPath: Path to your IPA file. Optional if you use the _gym_ or _xcodebuild_ action
   - googleserviceInfoPlistPath: Path to your GoogleService-Info.plist file, relative to the archived product path (or directly, if no archived product path is found)
   - apkPath: Path to your APK file
   - androidArtifactPath: Path to your APK or AAB file
   - androidArtifactType: Android artifact type. Set to 'APK' or 'AAB'. Defaults to 'APK' if not set
   - app: Your app's Firebase App ID. You can find the App ID in the Firebase console, on the General Settings page
   - firebaseCliPath: **DEPRECATED!** This plugin no longer uses the Firebase CLI - Absolute path of the Firebase CLI command
   - debug: Print verbose debug output
   - uploadTimeout: Amount of seconds before the upload will timeout, if not completed
   - uploadRetries: Maximum number of times the upload will retry, if not completed
   - groups: Group aliases used for distribution, separated by commas
   - groupsFile: Path to file containing group aliases used for distribution, separated by commas or newlines
   - testers: Email addresses of testers, separated by commas
   - testersFile: Path to file containing email addresses of testers, separated by commas or newlines
   - releaseNotes: Release notes for this build
   - releaseNotesFile: Path to file containing release notes for this build
   - testDevices: List of devices (separated by semicolons) to run automated tests on, in the format 'model=<model-id>,version=<os-version-id>,locale=<locale>,orientation=<orientation>;model=<model-id>,...'. Run 'gcloud firebase test android|ios models list' to see available devices. Note: This feature is in beta
   - testDevicesFile: Path to file containing a list of devices (sepatated by semicolons or newlines) to run automated tests on, in the format 'model=<model-id>,version=<os-version-id>,locale=<locale>,orientation=<orientation>;model=<model-id>,...'. Run 'gcloud firebase test android|ios models list' to see available devices. Note: This feature is in beta
   - testUsername: Username for automatic login
   - testPassword: Password for automatic login. If using a real password consider using test_password_file or setting FIREBASEAPPDISTRO_TEST_PASSWORD to avoid exposing sensitive info
   - testPasswordFile: Path to file containing password for automatic login
   - testUsernameResource: Resource name for the username field for automatic login
   - testPasswordResource: Resource name for the password field for automatic login
   - testNonBlocking: Run automated tests without waiting for them to finish. Visit the Firebase console for the test results
   - testCaseIds: Test Case IDs, separated by commas. Note: This feature is in beta
   - testCaseIdsFile: Path to file with containing Test Case IDs, separated by commas or newlines. Note: This feature is in beta
   - firebaseCliToken: Auth token generated using the Firebase CLI's login:ci command
   - serviceCredentialsFile: Path to Google service account json file
   - serviceCredentialsJsonData: Google service account json file content

 Release your beta builds with Firebase App Distribution
*/
public func firebaseAppDistribution(ipaPath: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                    googleserviceInfoPlistPath: String = "GoogleService-Info.plist",
                                    apkPath: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                    androidArtifactPath: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                    androidArtifactType: String = "APK",
                                    app: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                    firebaseCliPath: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                    debug: OptionalConfigValue<Bool> = .fastlaneDefault(false),
                                    uploadTimeout: Int = 300,
                                    uploadRetries: Int = 3,
                                    groups: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                    groupsFile: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                    testers: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                    testersFile: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                    releaseNotes: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                    releaseNotesFile: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                    testDevices: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                    testDevicesFile: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                    testUsername: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                    testPassword: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                    testPasswordFile: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                    testUsernameResource: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                    testPasswordResource: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                    testNonBlocking: OptionalConfigValue<Bool> = .fastlaneDefault(false),
                                    testCaseIds: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                    testCaseIdsFile: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                    firebaseCliToken: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                    serviceCredentialsFile: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                    serviceCredentialsJsonData: OptionalConfigValue<String?> = .fastlaneDefault(nil)) {
let ipaPathArg = ipaPath.asRubyArgument(name: "ipa_path", type: nil)
let googleserviceInfoPlistPathArg = RubyCommand.Argument(name: "googleservice_info_plist_path", value: googleserviceInfoPlistPath, type: nil)
let apkPathArg = apkPath.asRubyArgument(name: "apk_path", type: nil)
let androidArtifactPathArg = androidArtifactPath.asRubyArgument(name: "android_artifact_path", type: nil)
let androidArtifactTypeArg = RubyCommand.Argument(name: "android_artifact_type", value: androidArtifactType, type: nil)
let appArg = app.asRubyArgument(name: "app", type: nil)
let firebaseCliPathArg = firebaseCliPath.asRubyArgument(name: "firebase_cli_path", type: nil)
let debugArg = debug.asRubyArgument(name: "debug", type: nil)
let uploadTimeoutArg = RubyCommand.Argument(name: "upload_timeout", value: uploadTimeout, type: nil)
let uploadRetriesArg = RubyCommand.Argument(name: "upload_retries", value: uploadRetries, type: nil)
let groupsArg = groups.asRubyArgument(name: "groups", type: nil)
let groupsFileArg = groupsFile.asRubyArgument(name: "groups_file", type: nil)
let testersArg = testers.asRubyArgument(name: "testers", type: nil)
let testersFileArg = testersFile.asRubyArgument(name: "testers_file", type: nil)
let releaseNotesArg = releaseNotes.asRubyArgument(name: "release_notes", type: nil)
let releaseNotesFileArg = releaseNotesFile.asRubyArgument(name: "release_notes_file", type: nil)
let testDevicesArg = testDevices.asRubyArgument(name: "test_devices", type: nil)
let testDevicesFileArg = testDevicesFile.asRubyArgument(name: "test_devices_file", type: nil)
let testUsernameArg = testUsername.asRubyArgument(name: "test_username", type: nil)
let testPasswordArg = testPassword.asRubyArgument(name: "test_password", type: nil)
let testPasswordFileArg = testPasswordFile.asRubyArgument(name: "test_password_file", type: nil)
let testUsernameResourceArg = testUsernameResource.asRubyArgument(name: "test_username_resource", type: nil)
let testPasswordResourceArg = testPasswordResource.asRubyArgument(name: "test_password_resource", type: nil)
let testNonBlockingArg = testNonBlocking.asRubyArgument(name: "test_non_blocking", type: nil)
let testCaseIdsArg = testCaseIds.asRubyArgument(name: "test_case_ids", type: nil)
let testCaseIdsFileArg = testCaseIdsFile.asRubyArgument(name: "test_case_ids_file", type: nil)
let firebaseCliTokenArg = firebaseCliToken.asRubyArgument(name: "firebase_cli_token", type: nil)
let serviceCredentialsFileArg = serviceCredentialsFile.asRubyArgument(name: "service_credentials_file", type: nil)
let serviceCredentialsJsonDataArg = serviceCredentialsJsonData.asRubyArgument(name: "service_credentials_json_data", type: nil)
let array: [RubyCommand.Argument?] = [ipaPathArg,
googleserviceInfoPlistPathArg,
apkPathArg,
androidArtifactPathArg,
androidArtifactTypeArg,
appArg,
firebaseCliPathArg,
debugArg,
uploadTimeoutArg,
uploadRetriesArg,
groupsArg,
groupsFileArg,
testersArg,
testersFileArg,
releaseNotesArg,
releaseNotesFileArg,
testDevicesArg,
testDevicesFileArg,
testUsernameArg,
testPasswordArg,
testPasswordFileArg,
testUsernameResourceArg,
testPasswordResourceArg,
testNonBlockingArg,
testCaseIdsArg,
testCaseIdsFileArg,
firebaseCliTokenArg,
serviceCredentialsFileArg,
serviceCredentialsJsonDataArg]
let args: [RubyCommand.Argument] = array
.filter { $0?.value != nil }
.compactMap { $0 }
let command = RubyCommand(commandID: "", methodName: "firebase_app_distribution", className: nil, args: args)
  _ = runner.executeCommand(command)
}

/**
 Create testers in bulk from a comma-separated list or a file

 - parameters:
   - projectNumber: Your Firebase project number. You can find the project number in the Firebase console, on the General Settings page
   - emails: Comma separated list of tester emails to be created. A maximum of 1000 testers can be created at a time
   - file: Path to a file containing a comma separated list of tester emails to be created. A maximum of 1000 testers can be deleted at a time
   - groupAlias: Alias of the group to add the specified testers to. The group must already exist. If not specified, testers will not be added to a group
   - serviceCredentialsFile: Path to Google service credentials file
   - serviceCredentialsJsonData: Google service account json file content
   - firebaseCliToken: Auth token generated using the Firebase CLI's login:ci command
   - debug: Print verbose debug output

 Create testers in bulk from a comma-separated list or a file
*/
public func firebaseAppDistributionAddTesters(projectNumber: Int,
                                              emails: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                              file: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                              groupAlias: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                              serviceCredentialsFile: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                              serviceCredentialsJsonData: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                              firebaseCliToken: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                              debug: OptionalConfigValue<Bool> = .fastlaneDefault(false)) {
let projectNumberArg = RubyCommand.Argument(name: "project_number", value: projectNumber, type: nil)
let emailsArg = emails.asRubyArgument(name: "emails", type: nil)
let fileArg = file.asRubyArgument(name: "file", type: nil)
let groupAliasArg = groupAlias.asRubyArgument(name: "group_alias", type: nil)
let serviceCredentialsFileArg = serviceCredentialsFile.asRubyArgument(name: "service_credentials_file", type: nil)
let serviceCredentialsJsonDataArg = serviceCredentialsJsonData.asRubyArgument(name: "service_credentials_json_data", type: nil)
let firebaseCliTokenArg = firebaseCliToken.asRubyArgument(name: "firebase_cli_token", type: nil)
let debugArg = debug.asRubyArgument(name: "debug", type: nil)
let array: [RubyCommand.Argument?] = [projectNumberArg,
emailsArg,
fileArg,
groupAliasArg,
serviceCredentialsFileArg,
serviceCredentialsJsonDataArg,
firebaseCliTokenArg,
debugArg]
let args: [RubyCommand.Argument] = array
.filter { $0?.value != nil }
.compactMap { $0 }
let command = RubyCommand(commandID: "", methodName: "firebase_app_distribution_add_testers", className: nil, args: args)
  _ = runner.executeCommand(command)
}

/**
 Create a tester group

 - parameters:
   - projectNumber: Your Firebase project number. You can find the project number in the Firebase console, on the General Settings page
   - alias: Alias of the group to be created
   - displayName: Display name for the group to be created
   - serviceCredentialsFile: Path to Google service credentials file
   - serviceCredentialsJsonData: Google service account json file content
   - firebaseCliToken: Auth token generated using the Firebase CLI's login:ci command
   - debug: Print verbose debug output

 Create a tester group
*/
public func firebaseAppDistributionCreateGroup(projectNumber: Int,
                                               alias: String,
                                               displayName: String,
                                               serviceCredentialsFile: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                               serviceCredentialsJsonData: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                               firebaseCliToken: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                               debug: OptionalConfigValue<Bool> = .fastlaneDefault(false)) {
let projectNumberArg = RubyCommand.Argument(name: "project_number", value: projectNumber, type: nil)
let aliasArg = RubyCommand.Argument(name: "alias", value: alias, type: nil)
let displayNameArg = RubyCommand.Argument(name: "display_name", value: displayName, type: nil)
let serviceCredentialsFileArg = serviceCredentialsFile.asRubyArgument(name: "service_credentials_file", type: nil)
let serviceCredentialsJsonDataArg = serviceCredentialsJsonData.asRubyArgument(name: "service_credentials_json_data", type: nil)
let firebaseCliTokenArg = firebaseCliToken.asRubyArgument(name: "firebase_cli_token", type: nil)
let debugArg = debug.asRubyArgument(name: "debug", type: nil)
let array: [RubyCommand.Argument?] = [projectNumberArg,
aliasArg,
displayNameArg,
serviceCredentialsFileArg,
serviceCredentialsJsonDataArg,
firebaseCliTokenArg,
debugArg]
let args: [RubyCommand.Argument] = array
.filter { $0?.value != nil }
.compactMap { $0 }
let command = RubyCommand(commandID: "", methodName: "firebase_app_distribution_create_group", className: nil, args: args)
  _ = runner.executeCommand(command)
}

/**
 Delete a tester group

 - parameters:
   - projectNumber: Your Firebase project number. You can find the project number in the Firebase console, on the General Settings page
   - alias: Alias of the group to be deleted
   - serviceCredentialsFile: Path to Google service credentials file
   - serviceCredentialsJsonData: Google service account json file content
   - firebaseCliToken: Auth token generated using the Firebase CLI's login:ci command
   - debug: Print verbose debug output

 Delete a tester group
*/
public func firebaseAppDistributionDeleteGroup(projectNumber: Int,
                                               alias: String,
                                               serviceCredentialsFile: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                               serviceCredentialsJsonData: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                               firebaseCliToken: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                               debug: OptionalConfigValue<Bool> = .fastlaneDefault(false)) {
let projectNumberArg = RubyCommand.Argument(name: "project_number", value: projectNumber, type: nil)
let aliasArg = RubyCommand.Argument(name: "alias", value: alias, type: nil)
let serviceCredentialsFileArg = serviceCredentialsFile.asRubyArgument(name: "service_credentials_file", type: nil)
let serviceCredentialsJsonDataArg = serviceCredentialsJsonData.asRubyArgument(name: "service_credentials_json_data", type: nil)
let firebaseCliTokenArg = firebaseCliToken.asRubyArgument(name: "firebase_cli_token", type: nil)
let debugArg = debug.asRubyArgument(name: "debug", type: nil)
let array: [RubyCommand.Argument?] = [projectNumberArg,
aliasArg,
serviceCredentialsFileArg,
serviceCredentialsJsonDataArg,
firebaseCliTokenArg,
debugArg]
let args: [RubyCommand.Argument] = array
.filter { $0?.value != nil }
.compactMap { $0 }
let command = RubyCommand(commandID: "", methodName: "firebase_app_distribution_delete_group", className: nil, args: args)
  _ = runner.executeCommand(command)
}

/**
 Fetches the latest release in Firebase App Distribution

 - parameters:
   - googleserviceInfoPlistPath: Path to your GoogleService-Info.plist file, relative to the archived product path (or directly, if no archived product path is found)
   - app: Your app's Firebase App ID. You can find the App ID in the Firebase console, on the General Settings page
   - firebaseCliToken: Auth token generated using Firebase CLI's login:ci command
   - serviceCredentialsFile: Path to Google service account json
   - serviceCredentialsJsonData: Google service account json file content
   - debug: Print verbose debug output

 - returns: Hash representation of the lastest release created in Firebase App Distribution (see https://firebase.google.com/docs/reference/app-distribution/rest/v1/projects.apps.releases#resource:-release). Example: {:name=>"projects/123456789/apps/1:1234567890:ios:0a1b2c3d4e5f67890/releases/0a1b2c3d4", :releaseNotes=>{:text=>"Here are some release notes!"}, :displayVersion=>"1.2.3", :buildVersion=>"10", :binaryDownloadUri=>"<URI>", :firebaseConsoleUri=>"<URI>", :testingUri=>"<URI>", :createTime=>"2021-10-06T15:01:23Z"}

 Fetches information about the most recently created release in App Distribution, including the version and release notes. Returns nil if no releases are found.
*/
@discardableResult public func firebaseAppDistributionGetLatestRelease(googleserviceInfoPlistPath: String = "GoogleService-Info.plist",
                                                                       app: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                                                       firebaseCliToken: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                                                       serviceCredentialsFile: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                                                       serviceCredentialsJsonData: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                                                       debug: OptionalConfigValue<Bool> = .fastlaneDefault(false)) -> [String : Any] {
let googleserviceInfoPlistPathArg = RubyCommand.Argument(name: "googleservice_info_plist_path", value: googleserviceInfoPlistPath, type: nil)
let appArg = app.asRubyArgument(name: "app", type: nil)
let firebaseCliTokenArg = firebaseCliToken.asRubyArgument(name: "firebase_cli_token", type: nil)
let serviceCredentialsFileArg = serviceCredentialsFile.asRubyArgument(name: "service_credentials_file", type: nil)
let serviceCredentialsJsonDataArg = serviceCredentialsJsonData.asRubyArgument(name: "service_credentials_json_data", type: nil)
let debugArg = debug.asRubyArgument(name: "debug", type: nil)
let array: [RubyCommand.Argument?] = [googleserviceInfoPlistPathArg,
appArg,
firebaseCliTokenArg,
serviceCredentialsFileArg,
serviceCredentialsJsonDataArg,
debugArg]
let args: [RubyCommand.Argument] = array
.filter { $0?.value != nil }
.compactMap { $0 }
let command = RubyCommand(commandID: "", methodName: "firebase_app_distribution_get_latest_release", className: nil, args: args)
  return parseDictionary(fromString: runner.executeCommand(command))
}

/**
 Download the UDIDs of your Firebase App Distribution testers

 - parameters:
   - projectNumber: Your Firebase project number. You can find the project number in the Firebase console, on the General Settings page
   - app: **DEPRECATED!** Use project_number (FIREBASEAPPDISTRO_PROJECT_NUMBER) instead - Your app's Firebase App ID. You can find the App ID in the Firebase console, on the General Settings page
   - outputFile: The path to the file where the tester UDIDs will be written
   - firebaseCliToken: Auth token generated using the Firebase CLI's login:ci command
   - serviceCredentialsFile: Path to Google service account json
   - serviceCredentialsJsonData: Google service account json file content
   - debug: Print verbose debug output

 Export your testers' device identifiers in a CSV file, so you can add them your provisioning profile. This file can be imported into your Apple developer account using the Register Multiple Devices option. See the [App Distribution docs](https://firebase.google.com/docs/app-distribution/ios/distribute-console#register-tester-devices) for more info.
*/
public func firebaseAppDistributionGetUdids(projectNumber: OptionalConfigValue<Int?> = .fastlaneDefault(nil),
                                            app: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                            outputFile: String,
                                            firebaseCliToken: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                            serviceCredentialsFile: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                            serviceCredentialsJsonData: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                            debug: OptionalConfigValue<Bool> = .fastlaneDefault(false)) {
let projectNumberArg = projectNumber.asRubyArgument(name: "project_number", type: nil)
let appArg = app.asRubyArgument(name: "app", type: nil)
let outputFileArg = RubyCommand.Argument(name: "output_file", value: outputFile, type: nil)
let firebaseCliTokenArg = firebaseCliToken.asRubyArgument(name: "firebase_cli_token", type: nil)
let serviceCredentialsFileArg = serviceCredentialsFile.asRubyArgument(name: "service_credentials_file", type: nil)
let serviceCredentialsJsonDataArg = serviceCredentialsJsonData.asRubyArgument(name: "service_credentials_json_data", type: nil)
let debugArg = debug.asRubyArgument(name: "debug", type: nil)
let array: [RubyCommand.Argument?] = [projectNumberArg,
appArg,
outputFileArg,
firebaseCliTokenArg,
serviceCredentialsFileArg,
serviceCredentialsJsonDataArg,
debugArg]
let args: [RubyCommand.Argument] = array
.filter { $0?.value != nil }
.compactMap { $0 }
let command = RubyCommand(commandID: "", methodName: "firebase_app_distribution_get_udids", className: nil, args: args)
  _ = runner.executeCommand(command)
}

/**
 Delete testers in bulk from a comma-separated list or a file

 - parameters:
   - projectNumber: Your Firebase project number. You can find the project number in the Firebase console, on the General Settings page
   - emails: Comma separated list of tester emails to be deleted (or removed from a group if a group alias is specified). A maximum of 1000 testers can be deleted/removed at a time
   - file: Path to a file containing a comma separated list of tester emails to be deleted (or removed from a group if a group alias is specified). A maximum of 1000 testers can be deleted/removed at a time
   - groupAlias: Alias of the group to remove the specified testers from. Testers will not be deleted from the project
   - serviceCredentialsFile: Path to Google service credentials file
   - serviceCredentialsJsonData: Google service account json file content
   - firebaseCliToken: Auth token generated using the Firebase CLI's login:ci command
   - debug: Print verbose debug output

 Delete testers in bulk from a comma-separated list or a file
*/
public func firebaseAppDistributionRemoveTesters(projectNumber: Int,
                                                 emails: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                                 file: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                                 groupAlias: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                                 serviceCredentialsFile: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                                 serviceCredentialsJsonData: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                                 firebaseCliToken: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                                 debug: OptionalConfigValue<Bool> = .fastlaneDefault(false)) {
let projectNumberArg = RubyCommand.Argument(name: "project_number", value: projectNumber, type: nil)
let emailsArg = emails.asRubyArgument(name: "emails", type: nil)
let fileArg = file.asRubyArgument(name: "file", type: nil)
let groupAliasArg = groupAlias.asRubyArgument(name: "group_alias", type: nil)
let serviceCredentialsFileArg = serviceCredentialsFile.asRubyArgument(name: "service_credentials_file", type: nil)
let serviceCredentialsJsonDataArg = serviceCredentialsJsonData.asRubyArgument(name: "service_credentials_json_data", type: nil)
let firebaseCliTokenArg = firebaseCliToken.asRubyArgument(name: "firebase_cli_token", type: nil)
let debugArg = debug.asRubyArgument(name: "debug", type: nil)
let array: [RubyCommand.Argument?] = [projectNumberArg,
emailsArg,
fileArg,
groupAliasArg,
serviceCredentialsFileArg,
serviceCredentialsJsonDataArg,
firebaseCliTokenArg,
debugArg]
let args: [RubyCommand.Argument] = array
.filter { $0?.value != nil }
.compactMap { $0 }
let command = RubyCommand(commandID: "", methodName: "firebase_app_distribution_remove_testers", className: nil, args: args)
  _ = runner.executeCommand(command)
}
