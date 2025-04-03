//
//  SetUpDependencyManager.swift
//  iOSTemplateMaker
//
//  Created by Bui Minh Duc on 3/4/25.
//

import Foundation

struct SetUpDependencyManager {

    enum DependencyManager: Titlable, CaseIterable {

        case spm, cocoapods

        init?(_ name: String) {
            let lower = name.lowercased()
            if lower == "s" || lower == "spm" || lower.contains("swift") {
                self = .spm
            } else if lower == "c" || lower == "cocoapods" {
                self = .cocoapods
            } else {
                return nil
            }
        }

        var title: String {
            switch self {
            case .spm: return "Swift Package Manager"
            case .cocoapods: return "CocoaPods"
            }
        }
    }
}
