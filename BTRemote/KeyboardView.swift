import SwiftUI

enum KeyboardPage: Int, CaseIterable, Identifiable {
    case fullKeyboard = 0
    case trackpad = 1
    case classic = 2

    var id: Int { rawValue }

    var title: LocalizedStringKey {
        switch self {
        case .fullKeyboard: L10n.Keyboard.fullKeyboard
        case .trackpad: L10n.Keyboard.trackpad
        case .classic: L10n.Keyboard.classic
        }
    }

    var icon: String {
        switch self {
        case .fullKeyboard: "keyboard"
        case .trackpad: "hand.draw"
        case .classic: "rectangle.split.2x1"
        }
    }
}

struct KeyboardView: View {
    let goToSetup: () -> Void

    @Environment(\.hid) private var hid
    @AppStorage(AppSettings.developerModeKey) private var developerMode = false
    @AppStorage("BTRemote.keyboardPage") private var selectedPage = 0

    var body: some View {
        if hid.isActive || developerMode {
            VStack(spacing: 6) {
                pageSwitcher
                contentView
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            NotConnectedView(icon: "keyboard", goToSetup: goToSetup)
        }
    }

    private var pageSwitcher: some View {
        HStack(spacing: 6) {
            ForEach(KeyboardPage.allCases) { page in
                Button {
                    Haptics.tap()
                    withAnimation(.easeInOut(duration: 0.18)) {
                        selectedPage = page.rawValue
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: page.icon)
                            .font(.system(size: 12, weight: .semibold))
                        Text(page.title)
                            .font(.system(size: 12, weight: .semibold))
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 6)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(selectedPage == page.rawValue ? Color.accentColor : groupFill)
                    )
                    .foregroundColor(selectedPage == page.rawValue ? .white : .primary)
                }
                .buttonStyle(.plain)
            }
            Button {
                Haptics.tap()
                hid.toggleVirtualKeyboard()
            } label: {
                Image(systemName: "keyboard.chevron.compact.down")
                    .font(.system(size: 13, weight: .semibold))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(groupFill)
                    )
                    .foregroundColor(.primary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Toggle Onscreen Keyboard")
        }
        .padding(.horizontal, 8)
        .padding(.top, 4)
    }

    @ViewBuilder
    private var contentView: some View {
        switch selectedPage {
        case 0:
            FullKeyboardView()
        case 1:
            StandaloneTrackpadView(hid: hid)
        case 2:
            ClassicKeyboardView()
        default:
            FullKeyboardView()
        }
    }
}

#if DEBUG
    #Preview {
        KeyboardView(goToSetup: {})
    }
#endif
