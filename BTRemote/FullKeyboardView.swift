import SwiftUI

struct FullKeyboardView: View {
    @Environment(\.hid) private var hid
    @State private var mods: KeyboardModifiers = []
    @State private var isCapsLockOn = false

    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height
            if isLandscape {
                landscapeKeyboard(size: geo.size)
            } else {
                portraitKeyboard(size: geo.size)
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 4)
    }

    // MARK: - Landscape Keyboard (6 rows standard layout)

    private func landscapeKeyboard(size: CGSize) -> some View {
        let gap: CGFloat = 5
        let totalRows: CGFloat = 6
        let availableHeight = size.height - (totalRows - 1) * gap
        let keyHeight = min(52, max(28, availableHeight / totalRows))

        return VStack(spacing: gap) {
            keyRow(row0, width: size.width, gap: gap, height: keyHeight, isCompact: false)
            keyRow(row1, width: size.width, gap: gap, height: keyHeight, isCompact: false)
            keyRow(row2, width: size.width, gap: gap, height: keyHeight, isCompact: false)
            keyRow(row3, width: size.width, gap: gap, height: keyHeight, isCompact: false)
            keyRow(row4, width: size.width, gap: gap, height: keyHeight, isCompact: false)
            keyRow(row5, width: size.width, gap: gap, height: keyHeight, isCompact: false)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    // MARK: - Portrait Keyboard (scrollable comfortably-sized layout)

    private func portraitKeyboard(size: CGSize) -> some View {
        let keyHeight: CGFloat = 46
        let rowWidth: CGFloat = max(size.width, 700)
        let gap: CGFloat = 4

        return ScrollView(.horizontal, showsIndicators: false) {
            VStack(spacing: gap) {
                keyRow(row0, width: rowWidth, gap: gap, height: keyHeight, isCompact: false)
                keyRow(row1, width: rowWidth, gap: gap, height: keyHeight, isCompact: false)
                keyRow(row2, width: rowWidth, gap: gap, height: keyHeight, isCompact: false)
                keyRow(row3, width: rowWidth, gap: gap, height: keyHeight, isCompact: false)
                keyRow(row4, width: rowWidth, gap: gap, height: keyHeight, isCompact: false)
                keyRow(row5, width: rowWidth, gap: gap, height: keyHeight, isCompact: false)
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
        }
    }

    private func keyRow(_ keys: [FullKeyCap], width: CGFloat, gap: CGFloat, height: CGFloat, isCompact: Bool) -> some View {
        let totalWeight: CGFloat = 15.0
        let gaps = gap * CGFloat(max(keys.count - 1, 0))
        let unit = max(0, (width - gaps) / totalWeight)

        return HStack(spacing: gap) {
            ForEach(keys) { key in
                FullKeyCapButton(
                    key: key,
                    isCompact: isCompact,
                    isArmed: isKeyArmed(key),
                    isShiftActive: isShiftActive,
                    onPress: { handlePress(key) },
                    onRelease: { handleRelease(key) }
                )
                .frame(width: max(0, unit * key.weight), height: height)
            }
        }
    }

    private var isShiftActive: Bool {
        mods.contains(.leftShift) || mods.contains(.rightShift) || isCapsLockOn
    }

    private func isKeyArmed(_ key: FullKeyCap) -> Bool {
        switch key.action {
        case let .modifier(mod):
            return mods.contains(mod)
        case .capsLock:
            return isCapsLockOn
        case .key:
            return false
        }
    }

    private func handlePress(_ key: FullKeyCap) {
        switch key.action {
        case let .key(code):
            keyDown(code)
        case let .modifier(mod):
            toggleMod(mod)
        case .capsLock:
            toggleCapsLock()
        }
    }

    private func handleRelease(_ key: FullKeyCap) {
        if case .key = key.action {
            keyUp()
        }
    }

    private func keyDown(_ code: Keycode) {
        var effectiveMods = mods
        if isCapsLockOn && isLetter(code) {
            effectiveMods.insert(.leftShift)
        }
        hid.keyDown(code, modifiers: effectiveMods)
    }

    private func keyUp() {
        hid.keyUp()
    }

    private func toggleCapsLock() {
        isCapsLockOn.toggle()
        hid.tap(.capsLock, modifiers: mods)
    }

    private func toggleMod(_ mod: KeyboardModifiers) {
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
}

private struct FullKeyCapButton: View {
    let key: FullKeyCap
    let isCompact: Bool
    let isArmed: Bool
    let isShiftActive: Bool
    let onPress: () -> Void
    let onRelease: () -> Void

    @State private var pressed = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(isArmed ? Color.accentColor : groupFill)
            keyContent
                .foregroundColor(isArmed ? .white : .primary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .opacity(pressed ? 0.6 : 1)
        .contentShape(Rectangle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !pressed {
                        pressed = true
                        Haptics.tap()
                        onPress()
                    }
                }
                .onEnded { _ in
                    if pressed {
                        pressed = false
                        onRelease()
                    }
                }
        )
        .accessibilityLabel(key.accessibility)
    }

    @ViewBuilder
    private var keyContent: some View {
        switch key.label {
        case let .text(str):
            Text(str)
                .font(.system(size: isCompact ? 10 : 13, weight: .medium))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

        case let .letter(char):
            Text(isShiftActive ? char.uppercased() : char.lowercased())
                .font(.system(size: isCompact ? 12 : 16, weight: .semibold))

        case let .dual(top, bottom):
            VStack(spacing: isCompact ? 0 : 2) {
                Text(top)
                    .font(.system(size: isCompact ? 8 : 10, weight: isShiftActive ? .bold : .regular))
                    .foregroundColor(isArmed ? .white : (isShiftActive ? .primary : .secondary))
                Text(bottom)
                    .font(.system(size: isCompact ? 10 : 13, weight: isShiftActive ? .regular : .bold))
                    .foregroundColor(isArmed ? .white : (isShiftActive ? .secondary : .primary))
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
                    .fill(isArmed ? Color.red : Color.secondary.opacity(0.4))
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
}

#if DEBUG
    #Preview {
        FullKeyboardView()
    }
#endif
