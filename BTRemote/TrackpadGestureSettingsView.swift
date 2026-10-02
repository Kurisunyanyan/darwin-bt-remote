import SwiftUI

struct TrackpadGestureSettingsView: View {
    @AppStorage(AppSettings.invertScrollKey) private var invertScroll = false
    @AppStorage(AppSettings.pinchGestureActionKey) private var pinchAction = TrackpadGestureAction.zoom.rawValue
    @AppStorage(AppSettings.threeFingerSwipeUpKey) private var swipeUpAction = TrackpadGestureAction.appSwitcher.rawValue
    @AppStorage(AppSettings.threeFingerSwipeDownKey) private var swipeDownAction = TrackpadGestureAction.home.rawValue
    @AppStorage(AppSettings.threeFingerSwipeLeftKey) private var swipeLeftAction = TrackpadGestureAction.previousApp.rawValue
    @AppStorage(AppSettings.threeFingerSwipeRightKey) private var swipeRightAction = TrackpadGestureAction.nextApp.rawValue
    @AppStorage(AppSettings.threeFingerTapKey) private var threeFingerTapAction = TrackpadGestureAction.spotlight.rawValue

    var body: some View {
        Form {
            Section(
                header: Text(L10n.Gesture.sectionTitle),
                footer: Text(L10n.Gesture.invertScrollHint)
            ) {
                Toggle(L10n.Gesture.invertScroll, isOn: $invertScroll)
            }

            Section(header: Text(L10n.Gesture.mappingTitle)) {
                gesturePicker(L10n.Gesture.pinchToZoom, selection: $pinchAction)
                gesturePicker(L10n.Gesture.threeFingerSwipeUp, selection: $swipeUpAction)
                gesturePicker(L10n.Gesture.threeFingerSwipeDown, selection: $swipeDownAction)
                gesturePicker(L10n.Gesture.threeFingerSwipeLeft, selection: $swipeLeftAction)
                gesturePicker(L10n.Gesture.threeFingerSwipeRight, selection: $swipeRightAction)
                gesturePicker(L10n.Gesture.threeFingerTap, selection: $threeFingerTapAction)
            }
        }
        .navigationTitle(L10n.Gesture.sectionTitle)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    private func gesturePicker(_ title: LocalizedStringKey, selection: Binding<String>) -> some View {
        Picker(title, selection: selection) {
            ForEach(TrackpadGestureAction.allCases) { action in
                Text(action.title).tag(action.rawValue)
            }
        }
    }
}

#if DEBUG
#Preview {
    NavigationView {
        TrackpadGestureSettingsView()
    }
}
#endif
