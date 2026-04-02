//
//  Confirm.swift
//
//
//  Created by MarkG on 17/7/24.
//

import Foundation

enum ConfirmResult: String, Titlable, CaseIterable {

    case yes = "Yes"
    case no = "No"

    var title: String { rawValue }
}

func confirm(_ message: String) -> ConfirmResult {
    picker(title: message, options: ConfirmResult.allCases)
}
