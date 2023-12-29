import Foundation

struct SetUpCICDService {

    enum CICDService {

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
    }

    enum GithubRunnerType {

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
    }

    private let fileManager = FileManager.default

    func perform() {
        var service: CICDService? = nil
        while service == nil {
            print("Which CI/CD service do you use (Can be edited later) [(g)ithub/(b)itrise/(c)odemagic/(l)ater]: ")
            service = CICDService(readLine().string)
        }

        switch service {
        case .github:
            var runnerType: GithubRunnerType?
            while runnerType == nil {
                print("Which workflow runner do you want to use? [(m)acos-latest/(s)elf-hosted/(l)ater]: ")
                runnerType = GithubRunnerType(readLine().string)
            }
            print("Setting template for Github Actions")
            fileManager.removeItems(in: "bitrise.yml")
            fileManager.removeItems(in: "codemagic.yaml")
            fileManager.removeItems(in: ".github/workflows")
            fileManager.createDirectory(path: ".github/workflows")
            switch runnerType {
            case .macOSLatest:
                print("Configured to run on the latest macOS.")
                fileManager.moveFiles(in: ".github/project_workflows", to: ".github/workflows")
                fileManager.removeItems(in: ".github/project_workflows")
                fileManager.removeItems(in: ".github/self_hosted_project_workflows")
            case .selfHosted:
                print("Configured to run on self-hosted.")
                fileManager.moveFiles(in: ".github/self_hosted_project_workflows", to: ".github/workflows")
                fileManager.removeItems(in: ".github/project_workflows")
                fileManager.removeItems(in: ".github/self_hosted_project_workflows")
            case .later, .none:
                print("You can manually setup the runner later.")
            }
        case .bitrise:
            print("Setting template for Bitrise")
            fileManager.removeItems(in: "codemagic.yaml")
            fileManager.removeItems(in: ".github/workflows")
            fileManager.removeItems(in: ".github/project_workflows")
            fileManager.removeItems(in: ".github/self_hosted_project_workflows")
        case .codemagic:
            print("Setting template for CodeMagic")
            fileManager.removeItems(in: "bitrise.yml")
            fileManager.removeItems(in: ".github/workflows")
            fileManager.removeItems(in: ".github/project_workflows")
            fileManager.removeItems(in: ".github/self_hosted_project_workflows")
        case .later, .none:
            print("You can manually setup the template later.")
        }

        print("✅  Completed")
    }
}
