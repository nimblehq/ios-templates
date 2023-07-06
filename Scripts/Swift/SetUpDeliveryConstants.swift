#!/usr/bin/swift

import Foundation

let fileManager = FileManager.default

print("Do you want to set up Constants values? (Can be edited later) [Y/n]: ")

var arg = "y"

arg = readLine() ?? arg

switch arg.lowercased() {
    case "y", "yes":
        try safeShell("open -a Xcode fastlane/Constants/Constant.swift")
    default:
        print("✅  Completed. You can edit this file at 'fastlane/Constants/Constant.swift'.")
}
