//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  ___COPYRIGHT___
//

//
// Add this file to Main Target as well
//

import Foundation

protocol IdentifierProvidable {

    static var screenName: String { get }

    var identifier: String { get }

    static func identifier(of element: Self) -> String
}

extension IdentifierProvidable where Self: RawRepresentable, RawValue == String {

    var identifier: String { Self.screenName + "." + rawValue }

    static func identifier(of element: Self) -> String { return Self.screenName + "." + element.rawValue }
}
