// DO NOT MODIFY
// Automatically generated by Arkana (https://github.com/rogerluan/arkana)

import Foundation
import ArkanaKeysInterfaces

public enum ArkanaKeys {
    @inline(__always)
    fileprivate static let salt: [UInt8] = [
        0xa5, 0xce, 0xa8, 0x44, 0x68, 0x20, 0xd1, 0xac, 0x57, 0x48, 0x8d, 0xe2, 0xf3, 0x7d, 0x97, 0x57, 0x85, 0xc4, 0xf5, 0xcb, 0xff, 0x29, 0xef, 0x20, 0xe2, 0x49, 0x2b, 0x4d, 0xb4, 0x5c, 0xd9, 0xbe, 0xd1, 0x45, 0xdc, 0x85, 0x8b, 0x4a, 0xce, 0xc7, 0xd, 0x6f, 0x22, 0xa4, 0x93, 0x5f, 0x1, 0x32, 0xb, 0x1, 0xf0, 0x42, 0xfd, 0x51, 0, 0xd9, 0x7f, 0x1e, 0xbb, 0x60, 0x23, 0xd3, 0x9f, 0x10
    ]

    static func decode(encoded: [UInt8], cipher: [UInt8]) -> String {
        return String(decoding: encoded.enumerated().map { offset, element in
            element ^ cipher[offset % cipher.count]
        }, as: UTF8.self)
    }

    static func decode(encoded: [UInt8], cipher: [UInt8]) -> Bool {
        let stringValue: String = Self.decode(encoded: encoded, cipher: cipher)
        return Bool(stringValue)!
    }

    static func decode(encoded: [UInt8], cipher: [UInt8]) -> Int {
        let stringValue: String = Self.decode(encoded: encoded, cipher: cipher)
        return Int(stringValue)!
    }
}

public extension ArkanaKeys {
    struct Global: ArkanaKeysGlobalProtocol {
        public init() {}
    }
}

public extension ArkanaKeys {
    struct Staging: ArkanaKeysEnvironmentProtocol {
        public init() {}
    }
}

public extension ArkanaKeys {
    struct Release: ArkanaKeysEnvironmentProtocol {
        public init() {}
    }
}
