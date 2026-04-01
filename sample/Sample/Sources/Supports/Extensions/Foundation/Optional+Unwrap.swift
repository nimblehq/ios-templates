//
//  Optional+Unwrap.swift
//

import Foundation

public extension Optional where Wrapped == String {

    var string: String { self ?? "" }
}
