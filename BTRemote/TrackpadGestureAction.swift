import SwiftUI

enum TrackpadGestureAction: String, CaseIterable, Identifiable {
    case none = "none"
    case appSwitcher = "app_switcher"
    case home = "home"
    case dock = "dock"
    case previousApp = "previous_app"
    case nextApp = "next_app"
    case spotlight = "spotlight"
    case controlCenter = "control_center"
    case notificationCenter = "notification_center"
    case screenshot = "screenshot"
    case middleClick = "middle_click"
    case zoom = "zoom"
    case rotateLeft = "rotate_left"
    case rotateRight = "rotate_right"

    var id: String { rawValue }

    var title: LocalizedStringKey {
        switch self {
        case .none: L10n.Gesture.actionNone
        case .appSwitcher: L10n.Gesture.actionAppSwitcher
        case .home: L10n.Gesture.actionHome
        case .dock: L10n.Gesture.actionDock
        case .previousApp: L10n.Gesture.actionPreviousApp
        case .nextApp: L10n.Gesture.actionNextApp
        case .spotlight: L10n.Gesture.actionSpotlight
        case .controlCenter: L10n.Gesture.actionControlCenter
        case .notificationCenter: L10n.Gesture.actionNotificationCenter
        case .screenshot: L10n.Gesture.actionScreenshot
        case .middleClick: L10n.Gesture.actionMiddleClick
        case .zoom: L10n.Gesture.actionZoom
        case .rotateLeft: L10n.Gesture.actionRotateLeft
        case .rotateRight: L10n.Gesture.actionRotateRight
        }
    }

    var shortcutHint: String {
        switch self {
        case .none: ""
        case .appSwitcher: "Cmd+Up / Globe+Up"
        case .home: "Cmd+H / Globe+H"
        case .dock: "Globe+A"
        case .previousApp: "Cmd+Shift+Tab"
        case .nextApp: "Cmd+Tab"
        case .spotlight: "Cmd+Space"
        case .controlCenter: "Globe+C"
        case .notificationCenter: "Globe+N"
        case .screenshot: "Cmd+Shift+3"
        case .middleClick: "Mouse Middle Button"
        case .zoom: "Ctrl+Scroll"
        case .rotateLeft: "Cmd+Left / Cmd+L"
        case .rotateRight: "Cmd+R"
        }
    }

    @MainActor
    func execute(hid: HIDInput) {
        switch self {
        case .none:
            break
        case .appSwitcher:
            hid.tap(.upArrow, modifiers: .leftGUI)
        case .home:
            hid.tap(.h, modifiers: .leftGUI)
        case .dock:
            hid.tap(.a, modifiers: [.leftCtrl, .leftAlt])
        case .previousApp:
            hid.tap(.tab, modifiers: [.leftGUI, .leftShift])
        case .nextApp:
            hid.tap(.tab, modifiers: .leftGUI)
        case .spotlight:
            hid.tap(.space, modifiers: .leftGUI)
        case .controlCenter:
            hid.tap(.c, modifiers: [.leftCtrl, .leftAlt])
        case .notificationCenter:
            hid.tap(.n, modifiers: [.leftCtrl, .leftAlt])
        case .screenshot:
            hid.tap(.digit3, modifiers: [.leftGUI, .leftShift])
        case .middleClick:
            hid.click(.middle)
        case .zoom:
            break
        case .rotateLeft:
            hid.tap(.r, modifiers: [.leftGUI, .leftAlt])
        case .rotateRight:
            hid.tap(.r, modifiers: .leftGUI)
        }
    }
}
