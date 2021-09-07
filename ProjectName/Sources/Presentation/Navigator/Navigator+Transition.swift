//
//  Navigator+Transition.swift
//

import UIKit

extension Navigator {

    enum Transition {

        case root(window: UIWindow?)
        case navigation
        case modal
        case alert
    }
}
