//
//  Navigator+Transition.swift
//

import UIKit

extension Navigator {

    enum Transition {

        case root(window: UIWindow?)
        case navigation(transition: InteractiveTransitionProtocol? = nil)
        case modal
        case alert
    }
}
