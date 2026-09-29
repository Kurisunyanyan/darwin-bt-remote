import SwiftUI

struct FullKeyboardView: View {
    @Environment(\.hid) private var hid
    @State private var mods: KeyboardModifiers = []
    @State private var isCapsLockOn = false
    @StateObject private var typist = KeyTypist()

    var body: some View {
        GeometryReader { geo in
            let isCompact = geo.size.width < 560
            let gap: CGFloat = isCompact ? 3 : 5
            let totalRows: CGFloat = 6
            let availableHeight = geo.size.height - (totalRows - 1) * gap
            let keyHeight = min(isCompact ? 44 : 52, max(26, availableHeight / totalRows))

            VStack(spacing: gap) {
                keyRow(row0, unit: keyUnit(row0, width: geo.size.width, gap: gap), height: keyHeight, isCompact: isCompact)
                keyRow(row1, unit: keyUnit(row1, width: geo.size.width, gap: gap), height: keyHeight, isCompact: isCompact)
                keyRow(row2, unit: keyUnit(row2, width: geo.size.width, gap: gap), height: keyHeight, isCompact: isCompact)
                keyRow(row3, unit: keyUnit(row3, width: geo.size.width, gap: gap), height: keyHeight, isCompact: isCompact)
                keyRow(row4, unit: keyUnit(row4, width: geo.size.width, gap: gap), height: keyHeight, isCompact: isCompact)
                keyRow(row5, unit: keyUnit(row5, width: geo.size.width, gap: gap), height: keyHeight, isCompact: isCompact)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
    }

    private func keyUnit(_ keys: [FullKeyCap], width: CGFloat, gap: CGFloat) -> CGFloat {
        let totalWeight: CGFloat = 15.0
        let gaps = gap * CGFloat(max(keys.count - 1, 0))
        return max(0, (width - gaps) / totalWeight)
    }

    private func keyRow(_ keys: [FullKeyCap], unit: CGFloat, height: CGFloat, isCompact: Bool) -> some View {
        HStack(spacing: isCompact ? 3 : 5) {
            ForEach(keys) { key in
                keyCapButton(key, isCompact: isCompact)
                    .frame(width: max(0, unit * key.weight), height: height)
            }
        }
    }

    private func keyCapButton(_ key: FullKeyCap, isCompact: Bool) -> some View {
        let isArmed: Bool = {
            switch key.action {
            case let .modifier(mod):
                return mods.contains(mod)
            case .capsLock:
                return isCapsLockOn
            case .key:
                return false
            }
        }()

        return Button {
            switch key.action {
            case let .key(code):
                pressKey(code)
            case let .modifier(mod):
                toggleMod(mod)
            case .capsLock:
                toggleCapsLock()
            }
        } label: {
            keyContent(key.label, isCompact: isCompact, isArmed: isArmed)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isArmed ? Color.accentColor : groupFill)
                )
                .foregroundColor(isArmed ? .white : .primary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(key.accessibility)
    }

    @ViewBuilder
    private func keyContent(_ label: FullKeyCap.Label, isCompact: Bool, isArmed: Bool) -> some View {
        let isShifted = isShiftActive
        switch label {
        case let .text(str):
            Text(str)
                .font(.system(size: isCompact ? 10 : 13, weight: .medium))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

        case let .letter(char):
            Text(isShifted ? char.uppercased() : char.lowercased())
                .font(.system(size: isCompact ? 12 : 16, weight: .semibold))

        case let .dual(top, bottom):
            VStack(spacing: isCompact ? 0 : 2) {
                Text(top)
                    .font(.system(size: isCompact ? 8 : 10, weight: isShifted ? .bold : .regular))
                    .foregroundColor(isArmed ? .white : (isShifted ? .primary : .secondary))
                Text(bottom)
                    .font(.system(size: isCompact ? 10 : 13, weight: isShifted ? .regular : .bold))
                    .foregroundColor(isArmed ? .white : (isShifted ? .secondary : .primary))
            }

        case let .symbol(sysName, fallback):
            if isCompact {
                Image(systemName: sysName)
                    .font(.system(size: 11, weight: .medium))
            } else {
                HStack(spacing: 3) {
                    Image(systemName: sysName)
                        .font(.system(size: 11, weight: .medium))
                    if !fallback.isEmpty {
                        Text(fallback)
                            .font(.system(size: 11, weight: .medium))
                    }
                }
            }

        case .capsLock:
            HStack(spacing: 3) {
                Circle()
                    .fill(isCapsLockOn ? Color.red : Color.secondary.opacity(0.4))
                    .frame(width: isCompact ? 4 : 6, height: isCompact ? 4 : 6)
                Text(isCompact ? "Caps" : "Caps Lock")
                    .font(.system(size: isCompact ? 9 : 12, weight: .medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

        case let .modifier(name, symbol, _):
            if isCompact {
                Text(symbol.isEmpty ? name : symbol)
                    .font(.system(size: 10, weight: .medium))
            } else {
                HStack(spacing: 2) {
                    if !symbol.isEmpty {
                        Text(symbol)
                            .font(.system(size: 11, weight: .medium))
                    }
                    Text(name)
                        .font(.system(size: 11, weight: .medium))
                }
            }
        }
    }

    private var isShiftActive: Bool {
        mods.contains(.leftShift) || mods.contains(.rightShift) || isCapsLockOn
    }

    private func pressKey(_ code: Keycode) {
        Haptics.tap()
        typist.send = hid.sendKeyboard
        var effectiveMods = mods
        if isCapsLockOn && isLetter(code) {
            effectiveMods.insert(.leftShift)
        }
        typist.enqueue(HIDInput.keyReports(for: code, modifiers: effectiveMods))

        if !isNavigationKey(code) {
            if mods.contains(.leftShift) || mods.contains(.rightShift) {
                mods.subtract([.leftShift, .rightShift])
            }
            mods.subtract([.leftCtrl, .rightCtrl, .leftAlt, .rightAlt, .leftGUI, .rightGUI])
        }
    }

    private func toggleCapsLock() {
        Haptics.tap()
        isCapsLockOn.toggle()
        typist.send = hid.sendKeyboard
        typist.enqueue(HIDInput.keyReports(for: .capsLock, modifiers: mods))
    }

    private func toggleMod(_ mod: KeyboardModifiers) {
        Haptics.tap()
        if mods.contains(mod) {
            mods.subtract(mod)
        } else {
            mods.insert(mod)
        }
    }

    private func isLetter(_ key: Keycode) -> Bool {
        switch key {
        case .a, .b, .c, .d, .e, .f, .g, .h, .i, .j, .k, .l, .m,
             .n, .o, .p, .q, .r, .s, .t, .u, .v, .w, .x, .y, .z:
            return true
        default:
            return false
        }
    }

    private func isNavigationKey(_ key: Keycode) -> Bool {
        switch key {
        case .leftArrow, .rightArrow, .upArrow, .downArrow:
            return true
        default:
            return false
        }
    }

    // Row definitions - each row sums to weight 15.0

    private var row0: [FullKeyCap] {
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

    private var row1: [FullKeyCap] {
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
            FullKeyCap(.symbol("delete.left", "⌫"), weight: 2.0, L10n.Keyboard.backspace, .key(.backspace))
        ]
    }

    private var row2: [FullKeyCap] {
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

    private var row3: [FullKeyCap] {
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

    private var row4: [FullKeyCap] {
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
            FullKeyCap(.symbol("arrow.up", "↑"), weight: 1.0, L10n.Keyboard.up, .key(.upArrow)),
            FullKeyCap(.modifier(name: "Shift", symbol: "⇧", mod: .rightShift), weight: 1.9, L10n.Keyboard.shift, .modifier(.rightShift))
        ]
    }

    private var row5: [FullKeyCap] {
        [
            FullKeyCap(.modifier(name: "Ctrl", symbol: "⌃", mod: .leftCtrl), weight: 1.3, L10n.Keyboard.ctrl, .modifier(.leftCtrl)),
            FullKeyCap(.modifier(name: "Cmd", symbol: "⌘", mod: .leftGUI), weight: 1.2, L10n.Keyboard.meta, .modifier(.leftGUI)),
            FullKeyCap(.modifier(name: "Opt", symbol: "⌥", mod: .leftAlt), weight: 1.2, L10n.Keyboard.alt, .modifier(.leftAlt)),
            FullKeyCap(.text("Space"), weight: 5.3, L10n.Keyboard.space, .key(.space)),
            FullKeyCap(.modifier(name: "Opt", symbol: "⌥", mod: .rightAlt), weight: 1.2, L10n.Keyboard.alt, .modifier(.rightAlt)),
            FullKeyCap(.modifier(name: "Ctrl", symbol: "⌃", mod: .rightCtrl), weight: 1.3, L10n.Keyboard.ctrl, .modifier(.rightCtrl)),
            FullKeyCap(.symbol("arrow.left", "←"), weight: 1.16, L10n.Keyboard.left, .key(.leftArrow)),
            FullKeyCap(.symbol("arrow.down", "↓"), weight: 1.16, L10n.Keyboard.down, .key(.downArrow)),
            FullKeyCap(.symbol("arrow.right", "→"), weight: 1.18, L10n.Keyboard.right, .key(.rightArrow))
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

#if DEBUG
    #Preview {
        FullKeyboardView()
    }
#endif
