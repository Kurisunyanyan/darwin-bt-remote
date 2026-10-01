import SwiftUI

extension FullKeyboardView {
    // MARK: - Portrait 8-Row Layout (total weights: 10.0 per row)

    var pRow0: [FullKeyCap] {
        [
            FullKeyCap(.text("Esc"), weight: 1.25, L10n.Keyboard.esc, .key(.escape)),
            FullKeyCap(.text("F1"), weight: 1.25, "F1", .key(.f1)),
            FullKeyCap(.text("F2"), weight: 1.25, "F2", .key(.f2)),
            FullKeyCap(.text("F3"), weight: 1.25, "F3", .key(.f3)),
            FullKeyCap(.text("F4"), weight: 1.25, "F4", .key(.f4)),
            FullKeyCap(.text("F5"), weight: 1.25, "F5", .key(.f5)),
            FullKeyCap(.text("F6"), weight: 1.25, "F6", .key(.f6)),
            FullKeyCap(.text("PrtSc"), weight: 1.25, L10n.Keyboard.printScreen, .key(.printScreen))
        ]
    }

    var pRow1: [FullKeyCap] {
        [
            FullKeyCap(.text("Del"), weight: 1.4, L10n.Keyboard.deleteForward, .key(.deleteForward)),
            FullKeyCap(.text("F7"), weight: 1.2, "F7", .key(.f7)),
            FullKeyCap(.text("F8"), weight: 1.2, "F8", .key(.f8)),
            FullKeyCap(.text("F9"), weight: 1.2, "F9", .key(.f9)),
            FullKeyCap(.text("F10"), weight: 1.2, "F10", .key(.f10)),
            FullKeyCap(.text("F11"), weight: 1.2, "F11", .key(.f11)),
            FullKeyCap(.text("F12"), weight: 1.2, "F12", .key(.f12)),
            FullKeyCap(.text("PrtSc"), weight: 1.4, L10n.Keyboard.printScreen, .key(.printScreen))
        ]
    }

    var pRow2: [FullKeyCap] {
        [
            FullKeyCap(.dual(top: "~", bottom: "`"), weight: 0.9, "`", .key(.grave)),
            FullKeyCap(.dual(top: "!", bottom: "1"), weight: 0.91, "1", .key(.digit1)),
            FullKeyCap(.dual(top: "@", bottom: "2"), weight: 0.91, "2", .key(.digit2)),
            FullKeyCap(.dual(top: "#", bottom: "3"), weight: 0.91, "3", .key(.digit3)),
            FullKeyCap(.dual(top: "$", bottom: "4"), weight: 0.91, "4", .key(.digit4)),
            FullKeyCap(.dual(top: "%", bottom: "5"), weight: 0.91, "5", .key(.digit5)),
            FullKeyCap(.dual(top: "^", bottom: "6"), weight: 0.91, "6", .key(.digit6)),
            FullKeyCap(.dual(top: "&", bottom: "7"), weight: 0.91, "7", .key(.digit7)),
            FullKeyCap(.dual(top: "*", bottom: "8"), weight: 0.91, "8", .key(.digit8)),
            FullKeyCap(.dual(top: "(", bottom: "9"), weight: 0.91, "9", .key(.digit9)),
            FullKeyCap(.dual(top: ")", bottom: "0"), weight: 0.91, "0", .key(.digit0))
        ]
    }

    var pRow3: [FullKeyCap] {
        [
            FullKeyCap(.letter("Q"), weight: 1.0, "Q", .key(.q)),
            FullKeyCap(.letter("W"), weight: 1.0, "W", .key(.w)),
            FullKeyCap(.letter("E"), weight: 1.0, "E", .key(.e)),
            FullKeyCap(.letter("R"), weight: 1.0, "R", .key(.r)),
            FullKeyCap(.letter("T"), weight: 1.0, "T", .key(.t)),
            FullKeyCap(.letter("Y"), weight: 1.0, "Y", .key(.y)),
            FullKeyCap(.letter("U"), weight: 1.0, "U", .key(.u)),
            FullKeyCap(.letter("I"), weight: 1.0, "I", .key(.i)),
            FullKeyCap(.letter("O"), weight: 1.0, "O", .key(.o)),
            FullKeyCap(.letter("P"), weight: 1.0, "P", .key(.p))
        ]
    }

    var pRow4: [FullKeyCap] {
        [
            FullKeyCap(.letter("A"), weight: 1.0, "A", .key(.a)),
            FullKeyCap(.letter("S"), weight: 1.0, "S", .key(.s)),
            FullKeyCap(.letter("D"), weight: 1.0, "D", .key(.d)),
            FullKeyCap(.letter("F"), weight: 1.0, "F", .key(.f)),
            FullKeyCap(.letter("G"), weight: 1.0, "G", .key(.g)),
            FullKeyCap(.letter("H"), weight: 1.0, "H", .key(.h)),
            FullKeyCap(.letter("J"), weight: 1.0, "J", .key(.j)),
            FullKeyCap(.letter("K"), weight: 1.0, "K", .key(.k)),
            FullKeyCap(.letter("L"), weight: 1.0, "L", .key(.l))
        ]
    }

    var pRow5: [FullKeyCap] {
        [
            FullKeyCap(.modifier(name: "Shift", symbol: "⇧", mod: .leftShift), weight: 1.45, L10n.Keyboard.shift, .modifier(.leftShift)),
            FullKeyCap(.letter("Z"), weight: 1.0, "Z", .key(.z)),
            FullKeyCap(.letter("X"), weight: 1.0, "X", .key(.x)),
            FullKeyCap(.letter("C"), weight: 1.0, "C", .key(.c)),
            FullKeyCap(.letter("V"), weight: 1.0, "V", .key(.v)),
            FullKeyCap(.letter("B"), weight: 1.0, "B", .key(.b)),
            FullKeyCap(.letter("N"), weight: 1.0, "N", .key(.n)),
            FullKeyCap(.letter("M"), weight: 1.0, "M", .key(.m)),
            FullKeyCap(.symbol("delete.left", "⌫"), weight: 1.55, L10n.Keyboard.backspace, .key(.backspace))
        ]
    }

    var pRow6: [FullKeyCap] {
        [
            FullKeyCap(.symbol("arrow.right.to.line", "Tab"), weight: 1.0, L10n.Keyboard.tab, .key(.tab)),
            FullKeyCap(.dual(top: "_", bottom: "-"), weight: 0.9, "-", .key(.minus)),
            FullKeyCap(.dual(top: "+", bottom: "="), weight: 0.9, "=", .key(.equal)),
            FullKeyCap(.dual(top: "{", bottom: "["), weight: 0.9, "[", .key(.leftBracket)),
            FullKeyCap(.dual(top: "}", bottom: "]"), weight: 0.9, "]", .key(.rightBracket)),
            FullKeyCap(.dual(top: "|", bottom: "\\"), weight: 0.9, "\\", .key(.backslash)),
            FullKeyCap(.dual(top: ":", bottom: ";"), weight: 0.9, ";", .key(.semicolon)),
            FullKeyCap(.dual(top: "\"", bottom: "'"), weight: 0.9, "'", .key(.quote)),
            FullKeyCap(.dual(top: "<", bottom: ","), weight: 0.9, ",", .key(.comma)),
            FullKeyCap(.dual(top: ">", bottom: "."), weight: 0.9, ".", .key(.period)),
            FullKeyCap(.dual(top: "?", bottom: "/"), weight: 0.9, "/", .key(.slash))
        ]
    }

    var pRow7: [FullKeyCap] {
        [
            FullKeyCap(.modifier(name: "Ctrl", symbol: "⌃", mod: .leftCtrl), weight: 1.0, L10n.Keyboard.ctrl, .modifier(.leftCtrl)),
            FullKeyCap(.modifier(name: "Cmd", symbol: "⌘", mod: .leftGUI), weight: 1.0, L10n.Keyboard.meta, .modifier(.leftGUI)),
            FullKeyCap(.modifier(name: "Opt", symbol: "⌥", mod: .leftAlt), weight: 1.0, L10n.Keyboard.alt, .modifier(.leftAlt)),
            FullKeyCap(.capsLock, weight: 1.0, L10n.Keyboard.capsLock, .capsLock),
            FullKeyCap(.text("Space"), weight: 2.2, L10n.Keyboard.space, .key(.space)),
            FullKeyCap(.symbol("return", "Enter"), weight: 1.4, L10n.Keyboard.enter, .key(.return)),
            FullKeyCap(.symbol("arrow.left", "←"), weight: 0.6, L10n.Keyboard.left, .key(.leftArrow)),
            FullKeyCap(.symbol("arrow.up", "↑"), weight: 0.6, L10n.Keyboard.up, .key(.upArrow)),
            FullKeyCap(.symbol("arrow.down", "↓"), weight: 0.6, L10n.Keyboard.down, .key(.downArrow)),
            FullKeyCap(.symbol("arrow.right", "→"), weight: 0.6, L10n.Keyboard.right, .key(.rightArrow))
        ]
    }
}
