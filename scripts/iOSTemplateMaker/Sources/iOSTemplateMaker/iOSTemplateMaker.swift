import ArgumentParser
import Foundation

@main
struct iOSTemplateMaker: ParsableCommand {

    static let configuration: CommandConfiguration = CommandConfiguration(
        abstract: "Set up an iOS Project",
        subcommands: [
            Make.self,
            MakeTestFirebase.self,
            MakeTestTestFlight.self
        ],
        defaultSubcommand: Make.self
    )
}

extension iOSTemplateMaker {

    struct Make: ParsableCommand {

        @Option(help: "The production id (i.e. com.example.package)")
        var bundleIdProduction: String?
        @Option(help: "The staging id (i.e. com.example.package.staging)")
        var bundleIdStaging: String?
        @Option(help: "The project name (i.e. MyApp)")
        var projectName: String?
        @Option(help: "The minimum iOS version (14.0)")
        var minimumVersion: String?
        @Option(help: "The CI/CD service (github, bitrise, codemagic, none)")
        var cicd: String?
        @Option(help: "The GitHub runner type (macos-latest, self-hosted) — only used when --cicd=github")
        var githubRunner: String?
        @Flag(help: "Open Constant.swift to set up delivery constants after setup")
        var setupConstants: Bool = false

        mutating func run() {
            SetUpIOSProject(
                bundleIdProduction: bundleIdProduction.string,
                bundleIdStaging: bundleIdStaging.string,
                projectName: projectName.string,
                minimumVersion: minimumVersion.string,
                cicd: cicd.string,
                githubRunner: githubRunner.string,
                setupConstants: setupConstants
            ).perform()
        }
    }
}

extension iOSTemplateMaker {

    struct MakeTestFirebase: ParsableCommand {

        mutating func run() {
            let envMatchRepo = EnvironmentValue.value(for: .matchRepo).string
            let envStagingFirebaseAppId = EnvironmentValue.value(for: .stagingFirebaseAppId).string
            let envTeamId = EnvironmentValue.value(for: .teamId).string

            SetUpTestFirebase(
                matchRepo: envMatchRepo,
                stagingFirebaseAppId: envStagingFirebaseAppId,
                teamId: envTeamId
            ).perform()
        }
    }
}


extension iOSTemplateMaker {

    struct MakeTestTestFlight: ParsableCommand {

        mutating func run() {
            let envMatchRepo = EnvironmentValue.value(for: .matchRepo).string
            let envApiKey = EnvironmentValue.value(for: .apiKey).string
            let envIssuerId = EnvironmentValue.value(for: .issuerId).string
            let envTeamId = EnvironmentValue.value(for: .teamId).string

            SetUpTestTestFlight(
                matchRepo: envMatchRepo,
                apiKey: envApiKey,
                issuerId: envIssuerId,
                teamId: envTeamId
            ).perform()
        }
    }
}
