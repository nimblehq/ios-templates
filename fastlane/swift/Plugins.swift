import Foundation
/**
 Generate required icon sizes from a master application icon

 - parameters:
   - appiconImageFile: Path to a square image file, at least 512x512
   - appiconIconTypes: Array of device types to generate icons for
   - appiconPath: Path to res subfolder
   - appiconFilename: The output filename of each image
   - appiconCustomSizes: Hash of custom sizes - {'path/icon.png' => '256x256'}
   - generateRounded: Generate round icons?
   - minimagickCli: Set MiniMagick CLI (auto picked by default). Values are: graphicsmagick, imagemagick
*/
public func androidAppicon(appiconImageFile: String,
                           appiconIconTypes: [String] = [],
                           appiconPath: String = "app/res/mipmap",
                           appiconFilename: String = "ic_launcher",
                           appiconCustomSizes: [String : Any] = [:],
                           generateRounded: OptionalConfigValue<Bool> = .fastlaneDefault(false),
                           minimagickCli: OptionalConfigValue<String?> = .fastlaneDefault(nil)) {
let appiconImageFileArg = RubyCommand.Argument(name: "appicon_image_file", value: appiconImageFile, type: nil)
let appiconIconTypesArg = RubyCommand.Argument(name: "appicon_icon_types", value: appiconIconTypes, type: nil)
let appiconPathArg = RubyCommand.Argument(name: "appicon_path", value: appiconPath, type: nil)
let appiconFilenameArg = RubyCommand.Argument(name: "appicon_filename", value: appiconFilename, type: nil)
let appiconCustomSizesArg = RubyCommand.Argument(name: "appicon_custom_sizes", value: appiconCustomSizes, type: nil)
let generateRoundedArg = generateRounded.asRubyArgument(name: "generate_rounded", type: nil)
let minimagickCliArg = minimagickCli.asRubyArgument(name: "minimagick_cli", type: nil)
let array: [RubyCommand.Argument?] = [appiconImageFileArg,
appiconIconTypesArg,
appiconPathArg,
appiconFilenameArg,
appiconCustomSizesArg,
generateRoundedArg,
minimagickCliArg]
let args: [RubyCommand.Argument] = array
.filter { $0?.value != nil }
.compactMap { $0 }
let command = RubyCommand(commandID: "", methodName: "android_appicon", className: nil, args: args)
  _ = runner.executeCommand(command)
}

/**
 Generate required icon sizes and iconset from a master application icon

 - parameters:
   - appiconImageFile: Path to a square image file, at least 1024x1024
   - appiconDevices: Array of device idioms to generate icons for
   - appiconPath: Path to the Asset catalogue for the generated iconset
   - appiconName: Name of the appiconset inside the asset catalogue
   - appiconMessagesName: Name of the appiconset inside the asset catalogue
   - removeAlpha: Remove the alpha channel from generated PNG
   - messagesExtension: App icon is generated for Messages extension
   - minimagickCli: Set MiniMagick CLI (auto picked by default). Values are: graphicsmagick, imagemagick
*/
public func appicon(appiconImageFile: String,
                    appiconDevices: [String] = [],
                    appiconPath: String = "Assets.xcassets",
                    appiconName: String = "AppIcon.appiconset",
                    appiconMessagesName: String = "AppIcon.stickersiconset",
                    removeAlpha: OptionalConfigValue<Bool> = .fastlaneDefault(false),
                    messagesExtension: OptionalConfigValue<Bool> = .fastlaneDefault(false),
                    minimagickCli: OptionalConfigValue<String?> = .fastlaneDefault(nil)) {
let appiconImageFileArg = RubyCommand.Argument(name: "appicon_image_file", value: appiconImageFile, type: nil)
let appiconDevicesArg = RubyCommand.Argument(name: "appicon_devices", value: appiconDevices, type: nil)
let appiconPathArg = RubyCommand.Argument(name: "appicon_path", value: appiconPath, type: nil)
let appiconNameArg = RubyCommand.Argument(name: "appicon_name", value: appiconName, type: nil)
let appiconMessagesNameArg = RubyCommand.Argument(name: "appicon_messages_name", value: appiconMessagesName, type: nil)
let removeAlphaArg = removeAlpha.asRubyArgument(name: "remove_alpha", type: nil)
let messagesExtensionArg = messagesExtension.asRubyArgument(name: "messages_extension", type: nil)
let minimagickCliArg = minimagickCli.asRubyArgument(name: "minimagick_cli", type: nil)
let array: [RubyCommand.Argument?] = [appiconImageFileArg,
appiconDevicesArg,
appiconPathArg,
appiconNameArg,
appiconMessagesNameArg,
removeAlphaArg,
messagesExtensionArg,
minimagickCliArg]
let args: [RubyCommand.Argument] = array
.filter { $0?.value != nil }
.compactMap { $0 }
let command = RubyCommand(commandID: "", methodName: "appicon", className: nil, args: args)
  _ = runner.executeCommand(command)
}

/**
 Release your beta builds with Firebase App Distribution

 - parameters:
   - ipaPath: Path to your IPA file. Optional if you use the _gym_ or _xcodebuild_ action
   - googleserviceInfoPlistPath: Path to your GoogleService-Info.plist file, relative to the archived product path
   - apkPath: Path to your APK file
   - androidArtifactPath: Path to your APK or AAB file
   - androidArtifactType: Android artifact type. Set to 'APK' or 'AAB'. Defaults to 'APK' if not set
   - app: Your app's Firebase App ID. You can find the App ID in the Firebase console, on the General Settings page
   - firebaseCliPath: **DEPRECATED!** This plugin no longer uses the Firebase CLI - The absolute path of the firebase cli command
   - groups: The group aliases used for distribution, separated by commas
   - groupsFile: The group aliases used for distribution, separated by commas
   - testers: Pass email addresses of testers, separated by commas
   - testersFile: Pass email addresses of testers, separated by commas
   - releaseNotes: Release notes for this build
   - releaseNotesFile: Release notes file for this build
   - firebaseCliToken: Auth token generated using 'fastlane run firebase_app_distribution_login', or the Firebase CLI's login:ci command
   - debug: Print verbose debug output
   - serviceCredentialsFile: Path to Google service account json
   - uploadTimeout: The amount of seconds before the upload will timeout, if not completed

 Release your beta builds with Firebase App Distribution
*/
public func firebaseAppDistribution(ipaPath: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                    googleserviceInfoPlistPath: String = "GoogleService-Info.plist",
                                    apkPath: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                    androidArtifactPath: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                    androidArtifactType: String = "APK",
                                    app: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                    firebaseCliPath: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                    groups: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                    groupsFile: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                    testers: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                    testersFile: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                    releaseNotes: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                    releaseNotesFile: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                    firebaseCliToken: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                    debug: OptionalConfigValue<Bool> = .fastlaneDefault(false),
                                    serviceCredentialsFile: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                    uploadTimeout: Int = 300) {
let ipaPathArg = ipaPath.asRubyArgument(name: "ipa_path", type: nil)
let googleserviceInfoPlistPathArg = RubyCommand.Argument(name: "googleservice_info_plist_path", value: googleserviceInfoPlistPath, type: nil)
let apkPathArg = apkPath.asRubyArgument(name: "apk_path", type: nil)
let androidArtifactPathArg = androidArtifactPath.asRubyArgument(name: "android_artifact_path", type: nil)
let androidArtifactTypeArg = RubyCommand.Argument(name: "android_artifact_type", value: androidArtifactType, type: nil)
let appArg = app.asRubyArgument(name: "app", type: nil)
let firebaseCliPathArg = firebaseCliPath.asRubyArgument(name: "firebase_cli_path", type: nil)
let groupsArg = groups.asRubyArgument(name: "groups", type: nil)
let groupsFileArg = groupsFile.asRubyArgument(name: "groups_file", type: nil)
let testersArg = testers.asRubyArgument(name: "testers", type: nil)
let testersFileArg = testersFile.asRubyArgument(name: "testers_file", type: nil)
let releaseNotesArg = releaseNotes.asRubyArgument(name: "release_notes", type: nil)
let releaseNotesFileArg = releaseNotesFile.asRubyArgument(name: "release_notes_file", type: nil)
let firebaseCliTokenArg = firebaseCliToken.asRubyArgument(name: "firebase_cli_token", type: nil)
let debugArg = debug.asRubyArgument(name: "debug", type: nil)
let serviceCredentialsFileArg = serviceCredentialsFile.asRubyArgument(name: "service_credentials_file", type: nil)
let uploadTimeoutArg = RubyCommand.Argument(name: "upload_timeout", value: uploadTimeout, type: nil)
let array: [RubyCommand.Argument?] = [ipaPathArg,
googleserviceInfoPlistPathArg,
apkPathArg,
androidArtifactPathArg,
androidArtifactTypeArg,
appArg,
firebaseCliPathArg,
groupsArg,
groupsFileArg,
testersArg,
testersFileArg,
releaseNotesArg,
releaseNotesFileArg,
firebaseCliTokenArg,
debugArg,
serviceCredentialsFileArg,
uploadTimeoutArg]
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
   - serviceCredentialsFile: Path to Google service credentials file
   - firebaseCliToken: Auth token generated using 'fastlane run firebase_app_distribution_login', or the Firebase CLI's login:ci command
   - debug: Print verbose debug output

 Create testers in bulk from a comma-separated list or a file
*/
public func firebaseAppDistributionAddTesters(projectNumber: Int,
                                              emails: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                              file: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                              serviceCredentialsFile: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                              firebaseCliToken: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                              debug: OptionalConfigValue<Bool> = .fastlaneDefault(false)) {
let projectNumberArg = RubyCommand.Argument(name: "project_number", value: projectNumber, type: nil)
let emailsArg = emails.asRubyArgument(name: "emails", type: nil)
let fileArg = file.asRubyArgument(name: "file", type: nil)
let serviceCredentialsFileArg = serviceCredentialsFile.asRubyArgument(name: "service_credentials_file", type: nil)
let firebaseCliTokenArg = firebaseCliToken.asRubyArgument(name: "firebase_cli_token", type: nil)
let debugArg = debug.asRubyArgument(name: "debug", type: nil)
let array: [RubyCommand.Argument?] = [projectNumberArg,
emailsArg,
fileArg,
serviceCredentialsFileArg,
firebaseCliTokenArg,
debugArg]
let args: [RubyCommand.Argument] = array
.filter { $0?.value != nil }
.compactMap { $0 }
let command = RubyCommand(commandID: "", methodName: "firebase_app_distribution_add_testers", className: nil, args: args)
  _ = runner.executeCommand(command)
}

/**
 Fetches the latest release in Firebase App Distribution

 - parameters:
   - app: Your app's Firebase App ID. You can find the App ID in the Firebase console, on the General Settings page
   - firebaseCliToken: Auth token generated using 'fastlane run firebase_app_distribution_login', or the Firebase CLI's login:ci command
   - serviceCredentialsFile: Path to Google service account json
   - debug: Print verbose debug output

 - returns: Hash representation of the lastest release created in Firebase App Distribution (see https://firebase.google.com/docs/reference/app-distribution/rest/v1/projects.apps.releases#resource:-release). Example: {:name=>"projects/123456789/apps/1:1234567890:ios:0a1b2c3d4e5f67890/releases/0a1b2c3d4", :releaseNotes=>{:text=>"Here are some release notes!"}, :displayVersion=>"1.2.3", :buildVersion=>"10", :createTime=>"2021-10-06T15:01:23Z"}

 Fetches information about the most recently created release in App Distribution, including the version and release notes. Returns nil if no releases are found.
*/
@discardableResult public func firebaseAppDistributionGetLatestRelease(app: String,
                                                                       firebaseCliToken: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                                                       serviceCredentialsFile: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                                                       debug: OptionalConfigValue<Bool> = .fastlaneDefault(false)) -> [String : Any] {
let appArg = RubyCommand.Argument(name: "app", value: app, type: nil)
let firebaseCliTokenArg = firebaseCliToken.asRubyArgument(name: "firebase_cli_token", type: nil)
let serviceCredentialsFileArg = serviceCredentialsFile.asRubyArgument(name: "service_credentials_file", type: nil)
let debugArg = debug.asRubyArgument(name: "debug", type: nil)
let array: [RubyCommand.Argument?] = [appArg,
firebaseCliTokenArg,
serviceCredentialsFileArg,
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
   - app: Your app's Firebase App ID. You can find the App ID in the Firebase console, on the General Settings page
   - outputFile: The path to the file where the tester UDIDs will be written
   - firebaseCliToken: Auth token generated using 'fastlane run firebase_app_distribution_login', or the Firebase CLI's login:ci command
   - serviceCredentialsFile: Path to Google service account json
   - debug: Print verbose debug output

 Export your testers' device identifiers in a CSV file, so you can add them your provisioning profile. This file can be imported into your Apple developer account using the Register Multiple Devices option. See the [App Distribution docs](https://firebase.google.com/docs/app-distribution/ios/distribute-console#register-tester-devices) for more info.
*/
public func firebaseAppDistributionGetUdids(app: String,
                                            outputFile: String,
                                            firebaseCliToken: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                            serviceCredentialsFile: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                            debug: OptionalConfigValue<Bool> = .fastlaneDefault(false)) {
let appArg = RubyCommand.Argument(name: "app", value: app, type: nil)
let outputFileArg = RubyCommand.Argument(name: "output_file", value: outputFile, type: nil)
let firebaseCliTokenArg = firebaseCliToken.asRubyArgument(name: "firebase_cli_token", type: nil)
let serviceCredentialsFileArg = serviceCredentialsFile.asRubyArgument(name: "service_credentials_file", type: nil)
let debugArg = debug.asRubyArgument(name: "debug", type: nil)
let array: [RubyCommand.Argument?] = [appArg,
outputFileArg,
firebaseCliTokenArg,
serviceCredentialsFileArg,
debugArg]
let args: [RubyCommand.Argument] = array
.filter { $0?.value != nil }
.compactMap { $0 }
let command = RubyCommand(commandID: "", methodName: "firebase_app_distribution_get_udids", className: nil, args: args)
  _ = runner.executeCommand(command)
}

/**
 Authenticate with Firebase App Distribution using a Google account.

 - parameter port: Port for the local web server which receives the response from Google's authorization server

 Log in to Firebase App Distribution using a Google account to generate an authentication token. This token is stored within an environment variable and used to authenticate with your Firebase project. See https://firebase.google.com/docs/app-distribution/ios/distribute-fastlane for more information.
*/
public func firebaseAppDistributionLogin(port: String = "8081") {
let portArg = RubyCommand.Argument(name: "port", value: port, type: nil)
let array: [RubyCommand.Argument?] = [portArg]
let args: [RubyCommand.Argument] = array
.filter { $0?.value != nil }
.compactMap { $0 }
let command = RubyCommand(commandID: "", methodName: "firebase_app_distribution_login", className: nil, args: args)
  _ = runner.executeCommand(command)
}

/**
 Delete testers in bulk from a comma-separated list or a file

 - parameters:
   - projectNumber: Your Firebase project number. You can find the project number in the Firebase console, on the General Settings page
   - emails: Comma separated list of tester emails to be deleted. A maximum of 1000 testers can be deleted at a time
   - file: Path to a file containing a comma separated list of tester emails to be deleted. A maximum of 1000 testers can be deleted at a time
   - serviceCredentialsFile: Path to Google service credentials file
   - firebaseCliToken: Auth token generated using 'fastlane run firebase_app_distribution_login', or the Firebase CLI's login:ci command
   - debug: Print verbose debug output

 Delete testers in bulk from a comma-separated list or a file
*/
public func firebaseAppDistributionRemoveTesters(projectNumber: Int,
                                                 emails: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                                 file: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                                 serviceCredentialsFile: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                                 firebaseCliToken: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                                                 debug: OptionalConfigValue<Bool> = .fastlaneDefault(false)) {
let projectNumberArg = RubyCommand.Argument(name: "project_number", value: projectNumber, type: nil)
let emailsArg = emails.asRubyArgument(name: "emails", type: nil)
let fileArg = file.asRubyArgument(name: "file", type: nil)
let serviceCredentialsFileArg = serviceCredentialsFile.asRubyArgument(name: "service_credentials_file", type: nil)
let firebaseCliTokenArg = firebaseCliToken.asRubyArgument(name: "firebase_cli_token", type: nil)
let debugArg = debug.asRubyArgument(name: "debug", type: nil)
let array: [RubyCommand.Argument?] = [projectNumberArg,
emailsArg,
fileArg,
serviceCredentialsFileArg,
firebaseCliTokenArg,
debugArg]
let args: [RubyCommand.Argument] = array
.filter { $0?.value != nil }
.compactMap { $0 }
let command = RubyCommand(commandID: "", methodName: "firebase_app_distribution_remove_testers", className: nil, args: args)
  _ = runner.executeCommand(command)
}
