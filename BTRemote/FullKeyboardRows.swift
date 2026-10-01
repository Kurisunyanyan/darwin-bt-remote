import SwiftUI

extension FullKeyboardView {
    // Row definitions - each row sums to weight 15.0

    var row0: [FullKeyCap] {
        [
            FullKeyCap(.text("Esc"), weight: 1.0, L10n.Keyboard.esc, .key(.escape)),
            FullKeyCap(.text("F1"), weight: 1.0, "F1", .key(.f1)),
            FullKeyCap(.text("F2"), weight: 1.0, "F2", .key(.f2)),
            FullKeyCap(.text("F3"), weight: 1.0, "F3", .key(.f3)),
            FullKeyCap(.text("F4"), weight: 1.0, "F4", .key(.f4)),
            FullKeyCap(.text("F5"), weight: 1.0, "F5", .key(.f5)),
            FullKeyCap(.text("F6"), weight: 1.0, "F6", .key(.f6)),
            FullKeyCap(.text("F7"), weight: 1.0, "F7", .key(.f7)),
            FullKeyCap(.text("F8"), weight: 1.0, "F8", .key(.f8)),
            FullKeyCap(.text("F9"), weight: 1.0, "F9", .key(.f9)),
            FullKeyCap(.text("F10"), weight: 1.0, "F10", .key(.f10)),
            FullKeyCap(.text("F11"), weight: 1.0, "F11", .key(.f11)),
            FullKeyCap(.text("F12"), weight: 1.0, "F12", .key(.f12)),
            FullKeyCap(.text("PrtSc"), weight: 1.0, L10n.Keyboard.printScreen, .key(.printScreen)),
            FullKeyCap(.text("Del"), weight: 1.0, L10n.Keyboard.deleteForward, .key(.deleteForward))
        ]
    }

    var row1: [FullKeyCap] {
        [
            FullKeyCap(.dual(top: "~", bottom: "`"), weight: 1.0, "`", .key(.grave)),
            FullKeyCap(.dual(top: "!", bottom: "1"), weight: 1.0, "1", .key(.digit1)),
            FullKeyCap(.dual(top: "@", bottom: "2"), weight: 1.0, "2", .key(.digit2)),
            FullKeyCap(.dual(top: "#", bottom: "3"), weight: 1.0, "3", .key(.digit3)),
            FullKeyCap(.dual(top: "$", bottom: "4"), weight: 1.0, "4", .key(.digit4)),
            FullKeyCap(.dual(top: "%", bottom: "5"), weight: 1.0, "5", .key(.digit5)),
            FullKeyCap(.dual(top: "^", bottom: "6"), weight: 1.0, "6", .key(.digit6)),
            FullKeyCap(.dual(top: "&", bottom: "7"), weight: 1.0, "7", .key(.digit7)),
            FullKeyCap(.dual(top: "*", bottom: "8"), weight: 1.0, "8", .key(.digit8)),
            FullKeyCap(.dual(top: "(", bottom: "9"), weight: 1.0, "9", .key(.digit9)),
            FullKeyCap(.dual(top: ")", bottom: "0"), weight: 1.0, "0", .key(.digit0)),
            FullKeyCap(.dual(top: "_", bottom: "-"), weight: 1.0, "-", .key(.minus)),
            FullKeyCap(.dual(top: "+", bottom: "="), weight: 1.0, "=", .key(.equal)),
            FullKeyCap(.symbol("delete.left", ""), weight: 2.0, L10n.Keyboard.backspace, .key(.backspace))
        ]
    }

    var row2: [FullKeyCap] {
        [
            FullKeyCap(.symbol("arrow.right.to.line", "Tab"), weight: 1.5, L10n.Keyboard.tab, .key(.tab)),
            FullKeyCap(.letter("Q"), weight: 1.0, "Q", .key(.q)),
            FullKeyCap(.letter("W"), weight: 1.0, "W", .key(.w)),
            FullKeyCap(.letter("E"), weight: 1.0, "E", .key(.e)),
            FullKeyCap(.letter("R"), weight: 1.0, "R", .key(.r)),
            FullKeyCap(.letter("T"), weight: 1.0, "T", .key(.t)),
            FullKeyCap(.letter("Y"), weight: 1.0, "Y", .key(.y)),
            FullKeyCap(.letter("U"), weight: 1.0, "U", .key(.u)),
            FullKeyCap(.letter("I"), weight: 1.0, "I", .key(.i)),
            FullKeyCap(.letter("O"), weight: 1.0, "O", .key(.o)),
            FullKeyCap(.letter("P"), weight: 1.0, "P", .key(.p)),
            FullKeyCap(.dual(top: "{", bottom: "["), weight: 1.0, "[", .key(.leftBracket)),
            FullKeyCap(.dual(top: "}", bottom: "]"), weight: 1.0, "]", .key(.rightBracket)),
            FullKeyCap(.dual(top: "|", bottom: "\\"), weight: 1.5, "\\", .key(.backslash))
        ]
    }

    var row3: [FullKeyCap] {
        [
            FullKeyCap(.capsLock, weight: 1.8, L10n.Keyboard.capsLock, .capsLock),
            FullKeyCap(.letter("A"), weight: 1.0, "A", .key(.a)),
            FullKeyCap(.letter("S"), weight: 1.0, "S", .key(.s)),
            FullKeyCap(.letter("D"), weight: 1.0, "D", .key(.d)),
            FullKeyCap(.letter("F"), weight: 1.0, "F", .key(.f)),
            FullKeyCap(.letter("G"), weight: 1.0, "G", .key(.g)),
            FullKeyCap(.letter("H"), weight: 1.0, "H", .key(.h)),
            FullKeyCap(.letter("J"), weight: 1.0, "J", .key(.j)),
            FullKeyCap(.letter("K"), weight: 1.0, "K", .key(.k)),
            FullKeyCap(.letter("L"), weight: 1.0, "L", .key(.l)),
            FullKeyCap(.dual(top: ":", bottom: ";"), weight: 1.0, ";", .key(.semicolon)),
            FullKeyCap(.dual(top: "\"", bottom: "'"), weight: 1.0, "'", .key(.quote)),
            FullKeyCap(.symbol("return", "Enter"), weight: 2.2, L10n.Keyboard.enter, .key(.return))
        ]
    }

    var row4: [FullKeyCap] {
        [
            FullKeyCap(.modifier(name: "Shift", symbol: "⇧", mod: .leftShift), weight: 2.1, L10n.Keyboard.shift, .modifier(.leftShift)),
            FullKeyCap(.letter("Z"), weight: 1.0, "Z", .key(.z)),
            FullKeyCap(.letter("X"), weight: 1.0, "X", .key(.x)),
            FullKeyCap(.letter("C"), weight: 1.0, "C", .key(.c)),
            FullKeyCap(.letter("V"), weight: 1.0, "V", .key(.v)),
            FullKeyCap(.letter("B"), weight: 1.0, "B", .key(.b)),
            FullKeyCap(.letter("N"), weight: 1.0, "N", .key(.n)),
            FullKeyCap(.letter("M"), weight: 1.0, "M", .key(.m)),
            FullKeyCap(.dual(top: "<", bottom: ","), weight: 1.0, ",", .key(.comma)),
            FullKeyCap(.dual(top: ">", bottom: "."), weight: 1.0, ".", .key(.period)),
            FullKeyCap(.dual(top: "?", bottom: "/"), weight: 1.0, "/", .key(.slash)),
            FullKeyCap(.symbol("arrow.up", ""), weight: 1.0, L10n.Keyboard.up, .key(.upArrow)),
            FullKeyCap(.modifier(name: "Shift", symbol: "⇧", mod: .rightShift), weight: 1.9, L10n.Keyboard.shift, .modifier(.rightShift))
        ]
    }

    var row5: [FullKeyCap] {
        [
            FullKeyCap(.modifier(name: "Ctrl", symbol: "⌃", mod: .leftCtrl), weight: 1.3, L10n.Keyboard.ctrl, .modifier(.leftCtrl)),
            FullKeyCap(.modifier(name: "Cmd", symbol: "⌘", mod: .leftGUI), weight: 1.2, L10n.Keyboard.meta, .modifier(.leftGUI)),
            FullKeyCap(.modifier(name: "Opt", symbol: "⌥", mod: .leftAlt), weight: 1.2, L10n.Keyboard.alt, .modifier(.leftAlt)),
            FullKeyCap(.text("Space"), weight: 5.3, L10n.Keyboard.space, .key(.space)),
            FullKeyCap(.modifier(name: "Opt", symbol: "⌥", mod: .rightAlt), weight: 1.2, L10n.Keyboard.alt, .modifier(.rightAlt)),
            FullKeyCap(.modifier(name: "Ctrl", symbol: "⌃", mod: .rightCtrl), weight: 1.3, L10n.Keyboard.ctrl, .modifier(.rightCtrl)),
            FullKeyCap(.symbol("arrow.left", ""), weight: 1.16, L10n.Keyboard.left, .key(.leftArrow)),
            FullKeyCap(.symbol("arrow.down", ""), weight: 1.16, L10n.Keyboard.down, .key(.downArrow)),
            FullKeyCap(.symbol("arrow.right", ""), weight: 1.18, L10n.Keyboard.right, .key(.rightArrow))
        ]
    }
}

struct FullKeyCap: Identifiable {
    let id = UUID()

    enum Label {
        case text(String)
        case letter(String)
        case dual(top: String, bottom: String)
        case symbol(String, String)
        case capsLock
        case modifier(name: String, symbol: String, mod: KeyboardModifiers)
    }

    enum Action {
        case key(Keycode)
        case modifier(KeyboardModifiers)
        case capsLock
    }

    let label: Label
    let weight: CGFloat
    let accessibility: LocalizedStringKey
    let action: Action

    init(_ label: Label, weight: CGFloat = 1.0, _ accessibility: LocalizedStringKey, _ action: Action) {
        self.label = label
        self.weight = weight
        self.accessibility = accessibility
        self.action = action
    }
}

