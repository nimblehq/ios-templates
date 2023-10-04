//
//  EnvironmentValue.swift
//  
//
//  Created by Bliss on 30/8/23.
//

import Foundation

enum EnvironmentValue {

    static func value(for key: String) -> String? {
        ProcessInfo.processInfo.environment[key]
    }
}
