//
//  Keychain.swift
//  FastlaneRunner
//
//  Created by Su Ho on 22/09/2022.
//  Copyright © 2022 Nimble. All rights reserved.
//

import Foundation
	
enum Keychain {

    static func create() {
        createKeychain(
            name: .userDefined(Constant.keychainName),
            password: Secret.keychainPassword,
            defaultKeychain: .userDefined(true),
            unlock: .userDefined(true),
            timeout: 3600
        )
    }
    
    static func remove() {
        guard FileManager.default.fileExists(atPath: Constant.keychainPath) else {
            return log(message: "Couldn't find the Keychain")
        }
        deleteKeychain(
            name: .userDefined(Constant.keychainName)
        )
    }
}
