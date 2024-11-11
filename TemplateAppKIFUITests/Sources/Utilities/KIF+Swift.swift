//  swiftlint:disable:this file_name
//
//  KIF+Swift.swift
//

import KIF

extension KIFSpec {

    static func tester(file: String = #file, _ line: Int = #line) -> KIFUITestActor {
        KIFUITestActor(inFile: file, atLine: line, delegate: kifDelegate)
    }

    static func system(file: String = #file, _ line: Int = #line) -> KIFSystemTestActor {
        KIFSystemTestActor(inFile: file, atLine: line, delegate: kifDelegate)
    }
}
