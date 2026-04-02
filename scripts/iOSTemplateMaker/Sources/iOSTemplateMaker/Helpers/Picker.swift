//
//  Picker.swift
//  
//
//  Created by MarkG on 15/7/24.
//

import ANSITerminal

protocol Titlable {

    var title: String { get }
}

fileprivate struct Option {

    let title: String
    let line: Int

    init(title: String, line: Int) {
        self.title = title
        self.line = line
    }
}

fileprivate class OptionState {

    let options: [Option]
    let rangeOfLines: (minimum: Int, maximum: Int)
    var activeLine: Int = .zero

    var activeIndex: Int {
        options.firstIndex { $0.line == activeLine } ?? .zero
    }

    var activeOption: Option? {
        options.first { $0.line == activeLine }
    }

    init(options: [Option], activeLine: Int, rangeOfLines: (minimum: Int, maximum: Int)) {
        self.activeLine = activeLine
        self.rangeOfLines = rangeOfLines
        self.options = options
    }
}

func picker<T: Titlable>(title: String, options: [T]) -> T {
    cursorOff()
    write("◆".foreColor(81).bold)
    moveRight()
    writeln(title)

    options.forEach {
        writeln($0.title)
    }
    moveUp(options.count)
    clearBelow()
    let currentLine = readCursorPos().row
    let state = OptionState(
        options: options.enumerated()
            .map { Option(title: $1.title, line: currentLine + $0) },
        activeLine: currentLine,
        rangeOfLines: (currentLine, currentLine + options.count - 1)
    )
    reRender(state: state)

    let restoreLine = options.count + 1
    while true {
        clearBuffer()

        if keyPressed() {
            let char = readChar()
            if char == NonPrintableChar.enter.char() {
                break
            }

            let key = readKey()

            switch key.code {
            case .up:
                if state.activeLine > state.rangeOfLines.minimum {
                    state.activeLine -= 1

                    moveUp(restoreLine)
                    reRender(state: state)
                }
            case .down:
                if state.activeLine < state.rangeOfLines.maximum {
                    state.activeLine += 1

                    moveUp(restoreLine)
                    reRender(state: state)
                }
            default: break
            }
        }
    }

    return options[state.activeIndex]
}

private func reRender(state: OptionState) {
    (state.rangeOfLines.minimum...state.rangeOfLines.maximum).forEach { line in
        let isActive = line == state.activeLine

        write("│".foreColor(81))

        moveRight()
        let stateIndicator = isActive ? "●".lightGreen : "○".foreColor(250)
        write(stateIndicator)

        if let title = state.options.first(where: {
            $0.line == line
        })?.title {
            let title = isActive ? title : title.foreColor(250)
            moveRight()
            writeln(title)
        }
    }

    writeln("└".foreColor(81))
}
