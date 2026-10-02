import Foundation

enum AppSettings {
    static let touchpadSensitivityKey = "BTRemote.touchpadSensitivity"
    static let scrollSensitivityKey = "BTRemote.scrollSensitivity"
    static let autoAdvertiseKey = "BTRemote.autoAdvertise"
    static let colorSchemeKey = "BTRemote.colorScheme"
    static let developerModeKey = "BTRemote.developerMode"
    static let useServiceChangedKey = "BTRemote.useServiceChanged"
    static let deviceNamesKey = "BTRemote.deviceNames"
    static let hasSeenWelcomeKey = "BTRemote.hasSeenWelcome"
    static let liveTypingKey = "BTRemote.liveTyping"
    static let remoteModeKey = "BTRemote.remoteMode"
    static let advertisedNameKey = "BTRemote.advertisedName"
    static let precisionTouchpadKey = "BTRemote.precisionTouchpad"
    static let naturalScrollKey = "BTRemote.naturalScroll"
    static let invertScrollKey = "BTRemote.invertScroll"
    static let pinchGestureActionKey = "BTRemote.pinchGestureAction"
    static let threeFingerSwipeUpKey = "BTRemote.threeFingerSwipeUp"
    static let threeFingerSwipeDownKey = "BTRemote.threeFingerSwipeDown"
    static let threeFingerSwipeLeftKey = "BTRemote.threeFingerSwipeLeft"
    static let threeFingerSwipeRightKey = "BTRemote.threeFingerSwipeRight"
    static let threeFingerTapKey = "BTRemote.threeFingerTap"
    static let fourFingerSwipeUpKey = "BTRemote.fourFingerSwipeUp"
    static let fourFingerSwipeDownKey = "BTRemote.fourFingerSwipeDown"
    static let fourFingerSwipeLeftKey = "BTRemote.fourFingerSwipeLeft"
    static let fourFingerSwipeRightKey = "BTRemote.fourFingerSwipeRight"
    static let fourFingerTapKey = "BTRemote.fourFingerTap"
    static let rotationGestureActionKey = "BTRemote.rotationGestureAction"
    static let doubleTapDragKey = "BTRemote.doubleTapDrag"

    static let maxAdvertisedNameLength = 26

    static let repoURL = URL(string: "https://github.com/jqssun/darwin-bt-remote")!
    static let instructionsURL = URL(string: "https://github.com/jqssun/darwin-bt-remote/blob/main/README.md")!

    static let defaultPointerSensitivity = 5.0
    static let pointerSensitivityRange = 0.5 ... 10.0
    static let defaultScrollSensitivity = 1.0
    static let scrollSensitivityRange = 0.5 ... 3.0
}
