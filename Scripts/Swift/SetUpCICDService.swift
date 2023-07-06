#!/usr/bin/swift

import Foundation

let fileManager = FileManager.default

print("Which CI/CD service do you use (Can be edited later) [(g)ithub/(b)itrise/(c)odemagic/(l)ater]: ")

var service = "later"

enum CICDService {
    case github, bitrise, codemagic, later

    init(_ name: String) {
        switch name {
        case "g", "github", "Github":
            self = .github
        case "b", "bitrise", "Bitrise":
            self = .bitrise
        case "c", "codemagic", "Codemagic":
            self = .codemagic
        default: self = .later
        }
    }
}

service = readLine() ?? service

let serviceType = CICDService(service)
switch serviceType {
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
case .later:
    print("You can manually setup the template later.")
}

print("✅  Completed")
