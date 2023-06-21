#!/usr/bin/swift

import Foundation

var interface = "UIKit"
switch CommandLine.arguments[1] {
  case "SwiftUI", "s", "S":
    print("=> 🦅 Setting up SwiftUI")
    interface = "SwiftUI"
  default:
    print("=> 🦉 Setting up UIKit")
    interface = "UIKit"
}

let fileManager = FileManager.default
let currentDirectory = fileManager.currentDirectoryPath

fileManager.moveFiles(in: "tuist/Interfaces/\(interface)/Pod", to: "")
fileManager.moveFiles(in: "tuist/Interfaces/\(interface)/Sources", to: "{PROJECT_NAME}/Sources")
try fileManager.removeItem(atPath: "\(currentDirectory)/tuist/Interfaces")
