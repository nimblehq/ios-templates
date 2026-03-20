import Foundation

struct SetUpCICDService {

    enum CICDService: Titlable, CaseIterable {

        case github, bitrise, codemagic, later

        init?(_ name: String) {
            let name = name.lowercased()
            let mappings: [String: Self] = [
                "g": .github,
                "github": .github,
                "b": .bitrise,
                "bitrise": .bitrise,
                "c": .codemagic,
                "codemagic": .codemagic,
                "l": .later,
                "later": .later,
                "none": .later
            ]

            if let matchedCase = mappings[name] {
                self = matchedCase
            } else {
                return nil
            }
        }

        var title: String {
            switch self {
            case .github:
                "GitHub"
            case .bitrise:
                "Bitrise"
            case .codemagic:
                "CodeMagic"
            case .later:
                "none"
            }
        }
    }

    enum GithubRunnerType: Titlable, CaseIterable {

        case macOSLatest, selfHosted, later

        init?(_ name: String) {
            let mappings: [String: Self] = [
                "m": .macOSLatest,
                "macos-latest": .macOSLatest,
                "s": .selfHosted,
                "self-hosted": .selfHosted,
                "l": .later,
                "later": .later
            ]

            let name = name.lowercased()
            if let matchedCase = mappings[name] {
                self = matchedCase
            } else {
                return nil
            }
        }

        var title: String {
            switch self {
            case .macOSLatest:
                "macos-latest"
            case .selfHosted:
                "self-hosted"
            case .later:
                "none"
            }
        }
    }

    private let fileManager = FileManager.default

    func perform(cicd: String = "", githubRunner: String = "") throws {
        let service = CICDService(cicd) ?? picker(
            title: "Which service do you use?",
            options: CICDService.allCases
        )

        switch service {
        case .github:
            let runnerType = GithubRunnerType(githubRunner) ?? picker(
                title: "Which workflow runner do you want to use?",
                options: GithubRunnerType.allCases
            )

            // Remove existing .github if present (e.g. from the template repo itself) so the rename succeeds
            try fileManager.removeItems(in: ".github")

            // Move all .github files (ISSUE_TEMPLATE, PULL_REQUEST_TEMPLATE, CODEOWNERS, etc.)
            try fileManager.rename(file: ".cicdtemplate/.github", to: ".github")

            // Remove the runner variant we're not using
            switch runnerType {
            case .macOSLatest:
                try fileManager.removeItems(in: ".github/self-hosted-workflows")
            case .selfHosted:
                try fileManager.moveFiles(in: ".github/self-hosted-workflows", to: ".github/workflows", overwrite: true)
                try fileManager.removeItems(in: ".github/self-hosted-workflows")
            case .later:
                print("You can manually setup the runner later.")
            }
        case .bitrise:
            try fileManager.rename(file: ".cicdtemplate/.bitrise/bitrise.yml", to: "bitrise.yml")
        case .codemagic:
            try fileManager.rename(file: ".cicdtemplate/.codemagic/codemagic.yaml", to: "codemagic.yaml")
        case .later:
            print("You can manually setup the template later.")
        }

        try fileManager.removeItems(in: ".cicdtemplate")
    }
}
