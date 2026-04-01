//
//  String+NilIfEmpty.swift
//

extension String {

    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
