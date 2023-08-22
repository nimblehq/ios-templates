struct SetUpCICDService {

    enum CICDService {

        case github, bitrise, codemagic, later

        init?(_ name: String) {
            switch name.lowercased() {
            case "g", "github":
                self = .github
            case "b", "bitrise":
                self = .bitrise
            case "c", "codemagic":
                self = .codemagic
            case "l", "later":
                self = .later
            default: 
                return nil
            }
        }
    }

    private let fileManager = FileManager.default

    func perform() {
        var service: CICDService? = nil
        while service == nil {
            print("Which CI/CD service do you use (Can be edited later) [(g)ithub/(b)itrise/(c)odemagic/(l)ater]: ")
            service = CICDService(readLine() ?? "")
        }

        switch service {
        case .github:
            print("Setting template for Github Actions")
            fileManager.removeItems(in: "bitrise.yml")
            fileManager.removeItems(in: "codemagic.yaml")
        case .bitrise:
            print("Setting template for Bitrise")
            fileManager.removeItems(in: "codemagic.yaml")
            fileManager.removeItems(in: ".github/workflows")
        case .codemagic:
            print("Setting template for CodeMagic")
            fileManager.removeItems(in: "bitrise.yml")
            fileManager.removeItems(in: ".github/workflows")
        case .later, .none:
            print("You can manually setup the template later.")
        }

        print("✅  Completed")
    }
}
