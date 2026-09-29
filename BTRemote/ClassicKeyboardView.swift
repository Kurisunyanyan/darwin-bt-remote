import SwiftUI

private let keyHeight: CGFloat = 44

struct ClassicKeyboardView: View {
    @Environment(\.hid) private var hid
    @AppStorage(AppSettings.liveTypingKey) private var liveTyping = true
    @State private var text = ""
    @State private var sent = ""
    @State private var resetting = false
    @State private var mods: KeyboardModifiers = []
    @FocusState private var focused: Bool
    @StateObject private var typist = KeyTypist()

    var body: some View {
        editor
    }

    private var editor: some View {
        GeometryReader { geo in
            if geo.size.width > geo.size.height {
                HStack(spacing: 12) {
                    VStack(spacing: 12) {
                        inputField
                        keyPanel
                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity)
                    TrackpadPanel(hid: hid).frame(width: geo.size.width * 0.42)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: 12) {
                    inputField
                    keyPanel
                    TrackpadPanel(hid: hid).frame(maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .padding()
        .onChange(of: liveTyping) { _ in clear() }
        #if os(iOS)
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) { accessoryBar }
            }
        #endif
    }

    @ViewBuilder
    private var accessoryBar: some View {
        accessoryKey("escape", L10n.Keyboard.esc) { press(.escape) }
        accessoryKey("arrow.right.to.line", L10n.Keyboard.tab) { press(.tab) }
        Button {
            Haptics.tap()
            toggle(.leftCtrl)
        } label: {
            Image(systemName: "control")
                .foregroundStyle(mods.contains(.leftCtrl) ? Color.accentColor : Color.primary)
        }
        .accessibilityLabel(L10n.Keyboard.ctrl)
        ArrowPad { press($0) }
        accessoryKey("delete.left", L10n.Keyboard.backspace) { press(.backspace) }
        Spacer()
        Button(L10n.Keyboard.done) { focused = false }
    }

    private func accessoryKey(_ symbol: String, _ label: LocalizedStringKey, _ tap: @escaping () -> Void) -> some View {
        Button {
            Haptics.tap()
            tap()
        } label: {
            Image(systemName: symbol).foregroundStyle(Color.primary)
        }
        .accessibilityLabel(label)
    }

    private var inputField: some View {
        HStack(spacing: 8) {
            TextField(L10n.Keyboard.prompt, text: $text)
                .textFieldStyle(.roundedBorder)
                .focused($focused)
                .autocorrectionDisabled()
            #if os(iOS)
                .textInputAutocapitalization(.never)
                .keyboardType(.asciiCapable)
            #endif
                .onChange(of: text) { handleChange($0) }
                .onSubmit { liveTyping ? press(.return) : send() }
            if !liveTyping {
                Button(L10n.Keyboard.send) { send() }
                    .buttonStyle(.borderedProminent)
                    .disabled(text.isEmpty)
            }
            Button(L10n.Keyboard.clear) { clear() }
                .buttonStyle(.bordered)
        }
    }

    private var keyPanel: some View {
        VStack(spacing: 6) {
            keyRow(fRow)
            keyRow(row1)
            keyRow(row2)
            keyRow(row3)
        }
    }

    private func keyRow(_ keys: [ClassicKeyCap]) -> some View {
        GeometryReader { geo in
            let total = keys.reduce(0) { $0 + $1.weight }
            let gaps = 6 * CGFloat(max(keys.count - 1, 0))
            let unit = max(0, (geo.size.width - gaps) / total)
            HStack(spacing: 6) {
                ForEach(Array(keys.enumerated()), id: \.offset) { _, key in
                    keyCapButton(key).frame(width: unit * key.weight)
                }
            }
            .frame(maxHeight: .infinity)
        }
        .frame(height: keyHeight)
    }

    private func keyCapButton(_ key: ClassicKeyCap) -> some View {
        let armed: Bool = {
            if case let .modifier(mod) = key.action { return mods.contains(mod) }
            return false
        }()
        return Button {
            Haptics.tap()
            switch key.action {
            case let .key(code): press(code)
            case let .modifier(mod): toggle(mod)
            }
        } label: {
            keyLabel(key.label)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(RoundedRectangle(cornerRadius: 6).fill(armed ? Color.accentColor : groupFill))
                .foregroundColor(armed ? .white : .primary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(key.accessibility)
    }

    @ViewBuilder
    private func keyLabel(_ label: ClassicKeyCap.Label) -> some View {
        switch label {
        case let .symbol(name): Image(systemName: name).font(.body)
        case let .text(value): Text(value).font(.footnote)
        case .blank: Color.clear
        }
    }

    private let fKeys: [(Keycode, String)] = [
        (.f1, "F1"), (.f2, "F2"), (.f3, "F3"), (.f4, "F4"), (.f5, "F5"), (.f6, "F6"),
        (.f7, "F7"), (.f8, "F8"), (.f9, "F9"), (.f10, "F10"), (.f11, "F11"), (.f12, "F12")
    ]

    private var fRow: [ClassicKeyCap] {
        fKeys.map { code, name in ClassicKeyCap(.text(LocalizedStringKey(name)), LocalizedStringKey(name), .key(code)) }
    }

    private var row1: [ClassicKeyCap] {
        [
            ClassicKeyCap(.symbol("escape"), L10n.Keyboard.esc, .key(.escape)),
            ClassicKeyCap(.symbol("arrow.right.to.line"), L10n.Keyboard.tab, .key(.tab)),
            ClassicKeyCap(.text(L10n.Keyboard.printScreen), L10n.Keyboard.printScreen, .key(.printScreen)),
            ClassicKeyCap(.symbol("arrow.up"), L10n.Keyboard.up, .key(.upArrow)),
            ClassicKeyCap(.symbol("delete.left"), weight: 1.5, L10n.Keyboard.backspace, .key(.backspace)),
            ClassicKeyCap(.symbol("return"), weight: 1.5, L10n.Keyboard.enter, .key(.return))
        ]
    }

    private var row2: [ClassicKeyCap] {
        [
            ClassicKeyCap(.symbol("shift"), L10n.Keyboard.shift, .modifier(.leftShift)),
            ClassicKeyCap(.symbol("command"), L10n.Keyboard.meta, .modifier(.leftGUI)),
            ClassicKeyCap(.symbol("arrow.left"), L10n.Keyboard.left, .key(.leftArrow)),
            ClassicKeyCap(.symbol("arrow.down"), L10n.Keyboard.down, .key(.downArrow)),
            ClassicKeyCap(.symbol("arrow.right"), L10n.Keyboard.right, .key(.rightArrow)),
            ClassicKeyCap(.symbol("command"), L10n.Keyboard.meta, .modifier(.rightGUI)),
            ClassicKeyCap(.symbol("shift"), L10n.Keyboard.shift, .modifier(.rightShift))
        ]
    }

    private var row3: [ClassicKeyCap] {
        [
            ClassicKeyCap(.symbol("control"), L10n.Keyboard.ctrl, .modifier(.leftCtrl)),
            ClassicKeyCap(.symbol("option"), L10n.Keyboard.alt, .modifier(.leftAlt)),
            ClassicKeyCap(.blank, weight: 3, L10n.Keyboard.space, .key(.space)),
            ClassicKeyCap(.text(L10n.Keyboard.altGr), L10n.Keyboard.altGr, .modifier(.rightAlt)),
            ClassicKeyCap(.symbol("control"), L10n.Keyboard.ctrl, .modifier(.rightCtrl))
        ]
    }

    private func press(_ key: Keycode) {
        typist.send = hid.sendKeyboard
        typist.enqueue(HIDInput.keyReports(for: key, modifiers: mods))
    }

    private func toggle(_ mod: KeyboardModifiers) {
        if mods.contains(mod) { mods.subtract(mod) } else { mods.insert(mod) }
    }

    // live typing: diff the field against what was already sent

    private func handleChange(_ new: String) {
        if resetting {
            resetting = false
            sent = new
            return
        }
        guard liveTyping else { return }
        typist.send = hid.sendKeyboard
        let prefix = new.commonPrefix(with: sent).count
        var reports: [KeyboardReport] = []
        for _ in 0 ..< (sent.count - prefix) {
            reports += HIDInput.keyReports(for: .backspace)
        }
        for character in new.dropFirst(prefix) {
            reports += HIDInput.keyReports(for: character, adding: mods)
        }
        typist.enqueue(reports)
        sent = new
    }

    private func send() {
        guard !text.isEmpty else { return }
        typist.send = hid.sendKeyboard
        var reports: [KeyboardReport] = []
        for character in text {
            reports += HIDInput.keyReports(for: character, adding: mods)
        }
        typist.enqueue(reports)
        clear()
    }

    private func clear() {
        resetting = true
        text = ""
        focused = true
    }
}

private struct ClassicKeyCap {
    enum Label {
        case symbol(String)
        case text(LocalizedStringKey)
        case blank
    }

    enum Action {
        case key(Keycode)
        case modifier(KeyboardModifiers)
    }

    let label: Label
    let weight: CGFloat
    let accessibility: LocalizedStringKey
    let action: Action

    init(_ label: Label, weight: CGFloat = 1, _ accessibility: LocalizedStringKey, _ action: Action) {
        self.label = label
        self.weight = weight
        self.accessibility = accessibility
        self.action = action
    }
}

private struct ArrowPad: View {
    let onArrow: (Keycode) -> Void

    @StateObject private var repeater = ArrowRepeater()

    var body: some View {
        ZStack {
            glyph("↑", .upArrow, dx: 0, dy: -8)
            glyph("↓", .downArrow, dx: 0, dy: 8)
            glyph("←", .leftArrow, dx: -10, dy: 0)
            glyph("→", .rightArrow, dx: 10, dy: 0)
        }
        .frame(width: 46, height: 34)
        .contentShape(Rectangle())
        .accessibilityLabel(L10n.Keyboard.arrows)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged {
                    repeater.fire = onArrow
                    if let key = _direction($0.translation) {
                        repeater.start(key)
                    } else {
                        repeater.stop()
                    }
                }
                .onEnded { _ in repeater.stop() }
        )
    }

    private func glyph(_ char: String, _ key: Keycode, dx: CGFloat, dy: CGFloat) -> some View {
        Text(char)
            .font(.system(size: 15))
            .foregroundStyle(Color.primary)
            .opacity(repeater.active == nil || repeater.active == key ? 1 : 0.25)
            .offset(x: dx, y: dy)
    }

    private func _direction(_ d: CGSize) -> Keycode? {
        guard hypot(d.width, d.height) >= 20 else { return nil }
        if abs(d.width) > abs(d.height) { return d.width > 0 ? .rightArrow : .leftArrow }
        return d.height > 0 ? .downArrow : .upArrow
    }
}

@MainActor
private final class ArrowRepeater: ObservableObject {
    var fire: ((Keycode) -> Void)?
    @Published private(set) var active: Keycode?

    private var task: Task<Void, Never>?

    func start(_ key: Keycode) {
        guard key != active else { return }
        stop()
        active = key
        fire?(key)
        task = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 500_000_000)
            while !Task.isCancelled {
                self?.fire?(key)
                try? await Task.sleep(nanoseconds: 100_000_000)
            }
        }
    }

    func stop() {
        task?.cancel()
        task = nil
        active = nil
    }
}

#if DEBUG
    #Preview {
        ClassicKeyboardView()
    }
#endif
