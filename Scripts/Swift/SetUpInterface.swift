#!/usr/bin/swift

import Foundation

let fileManager = FileManager.default

var interface = "UIKit"

switch CommandLine.arguments[1] {
  case "SwiftUI", "s", "S":
    print("=> 🦅 Setting up SwiftUI")
    interface = "SwiftUI"
    let swiftUIAppDirectory = "tuist/Interfaces/SwiftUI/Sources/Application"
    fileManager.rename(file: "\(swiftUIAppDirectory)/App.swift", to: "\(swiftUIAppDirectory)/\(CommandLine.arguments[2])App.swift")
  default:
    print("=> 🦉 Setting up UIKit")
    interface = "UIKit"
}

fileManager.moveFiles(in: "tuist/Interfaces/\(interface)/Pod", to: "")
fileManager.moveFiles(in: "tuist/Interfaces/\(interface)/Sources", to: "{PROJECT_NAME}/Sources")
fileManager.removeItems(in: "tuist/Interfaces")
