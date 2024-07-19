//
//  Echo.swift
//
//
//  Created by MarkG on 9/7/24.
//

import Foundation
import ANSITerminal

enum WriteStyle {

    case section
    case success
    case error
    case warning
}

func write(_ text: String, style: WriteStyle) {
    switch style {
    case .section:
        writeln("-------------------".green)
        writeln(text.green)
        writeln("-------------------".green)
    case .success:
        writeln(text.green)
    case .error:
        writeln(text.red)
    case .warning:
        writeln(text.yellow)
    }
}

func writeAt(_ row: Int, _ col: Int, _ text: String) {
    moveTo(row, col)
    write(text)
}

func ask(
    _ q: String,
    note: String? = nil,
    defaultValue: String? = nil,
    onValidate: (_ input: String) -> String?
) -> String {
    write("◆".foreColor(81).bold)
    moveRight()

    if defaultValue == nil {
        write(q)
        moveRight()
        writeln("(*)".red)
    } else {
        writeln(q)
    }

    if let note {
        writeln(note.gray)
    }
    
    var hasError = false
    while(true) {
        clearBuffer()
        let input = ask("> ")
        if let error = onValidate(input) {
            hasError = true
            write(error, style: .error)

            let count = getWroteLineCount(error) + 1
            moveUp(count)
            clearLine()
            continue
        }

        if hasError {
            clearBelow()
        }

        if input.isEmpty,
           let defaultValue {
            return defaultValue
        }

        return input
    }
}

func step(title: String, action: () throws -> Void) throws {
    writeln("→ \(title.uppercased())".bold)

    do {
        try action()
    } catch {
        let message = error as? String ?? error.localizedDescription
        write(message, style: .error)
        throw error
    }
}

private func getWroteLineCount(_ text: String) -> Int {
    let count = unexpand(text: text).count
    let col = readScreenSize().col
    return Int(ceil(Double(count) / Double(col)))
}

private func unexpand(text: String) -> String {
    var result = ""
    var spaceCount = 0
    for char in text {
        if char == " " {
            spaceCount += 1
        } else {
            if spaceCount > 0 {
                let tabs = String(repeating: "\t", count: spaceCount / 8)
                let spaces = String(repeating: " ", count: spaceCount % 8)
                result += tabs + spaces
                spaceCount = 0
            }
            result += String(char)
        }
    }
    if spaceCount > 0 {
        let tabs = String(repeating: "\t", count: spaceCount / 8)
        let spaces = String(repeating: " ", count: spaceCount % 8)
        result += tabs + spaces
    }
    return result
}
