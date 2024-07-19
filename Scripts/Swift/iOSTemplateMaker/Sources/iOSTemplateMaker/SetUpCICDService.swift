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
                "later": .later
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
                "Github"
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
                "macos": .macOSLatest,
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
                "macos"
            case .selfHosted:
                "self-hosted"
            case .later:
                "none"
            }
        }
    }

    private let fileManager = FileManager.default

    func perform() throws {
        let service = picker(
            title: "Which service do you use?",
            options: CICDService.allCases
        )

        switch service {
        case .github:
            let runnerType = picker(
                title: "Which workflow runner do you want to use?",
                options: GithubRunnerType.allCases
            )

            try fileManager.removeItems(in: "bitrise.yml")
            try fileManager.removeItems(in: "codemagic.yaml")
            try fileManager.removeItems(in: ".github/workflows")
            try fileManager.createDirectory(path: ".github/workflows")
            switch runnerType {
            case .macOSLatest:
                try fileManager.moveFiles(in: ".github/project_workflows", to: ".github/workflows")
                try fileManager.removeItems(in: ".github/project_workflows")
                try fileManager.removeItems(in: ".github/self_hosted_project_workflows")
            case .selfHosted:
                try fileManager.moveFiles(in: ".github/self_hosted_project_workflows", to: ".github/workflows")
                try fileManager.removeItems(in: ".github/project_workflows")
                try fileManager.removeItems(in: ".github/self_hosted_project_workflows")
            case .later:
                print("You can manually setup the runner later.")
            }
        case .bitrise:
            try fileManager.removeItems(in: "codemagic.yaml")
            try fileManager.removeItems(in: ".github/workflows")
            try fileManager.removeItems(in: ".github/project_workflows")
            try fileManager.removeItems(in: ".github/self_hosted_project_workflows")
        case .codemagic:
            try fileManager.removeItems(in: "bitrise.yml")
            try fileManager.removeItems(in: ".github/workflows")
            try fileManager.removeItems(in: ".github/project_workflows")
            try fileManager.removeItems(in: ".github/self_hosted_project_workflows")
        case .later:
            print("You can manually setup the template later.")
        }
    }
}
