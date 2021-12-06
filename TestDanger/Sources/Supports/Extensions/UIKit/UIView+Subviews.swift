//
//  UIView+Subviews.swift
//

import UIKit

extension UIView {

    func addSubviews(_ views: UIView...) {
        views.forEach(addSubview)
    }
}
