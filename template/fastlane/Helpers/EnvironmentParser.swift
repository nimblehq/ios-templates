//
//  EnvironmentParser.swift
//  FastlaneRunner
//
//  Created by Su T. on 09/11/2022.
//  Copyright © 2022 Nimble. All rights reserved.
//

import Foundation

enum EnvironmentParser {

    static func bool(key: String) -> Bool {
        string(key: key) == "true"
    }

    static func integer(key: String) -> Int? {
        Int(string(key: key))
    }

    static func string(key: String) -> String {
        environmentVariable(get: .userDefined(key))
    }
}
