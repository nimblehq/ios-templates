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

import UIKit

protocol AccessibilityIdentifiable: AnyObject {

    associatedtype Identifier: IdentifierProvidable
}

extension AccessibilityIdentifiable {

    func setAccessibilityIdentifier(of view: UIAccessibilityIdentification?, with identifier: Identifier) {
        view?.accessibilityIdentifier = identifier.identifier
    }

    func setAccessibilityIdentifier(with dictionary: [UIView?: Identifier]) {
        dictionary.forEach(setAccessibilityIdentifier)
    }
}

extension AccessibilityIdentifiable where Self: UIViewController {

    func setAccessibilityIdentifierDomainToView() {
        view.accessibilityIdentifier = Identifier.screenName
    }
}
