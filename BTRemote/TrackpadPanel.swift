import SwiftUI

struct TrackpadPanel: View {
    let hid: HIDInput

    @AppStorage(AppSettings.touchpadSensitivityKey) private var touchpadSensitivity = AppSettings.defaultPointerSensitivity
    @AppStorage(AppSettings.scrollSensitivityKey) private var scrollSensitivity = AppSettings.defaultScrollSensitivity
    @AppStorage(AppSettings.invertScrollKey) private var invertScroll = false
    @AppStorage(AppSettings.pinchGestureActionKey) private var pinchActionRaw = TrackpadGestureAction.zoom.rawValue
    @State private var activeButtons: MouseButtons = []
    #if os(macOS)
        @State private var dragOffset: CGSize = .zero
    #endif

    var body: some View {
        VStack(spacing: cellGap) {
            HStack(spacing: cellGap) {
                surface
                scrollColumn.frame(width: 46)
            }
            .frame(maxHeight: .infinity)
            mouseButtonsRow.frame(height: 52)
        }
    }

    private var surface: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12).fill(groupFill)
            #if os(iOS)
                TouchpadView(
                    moveSensitivity: touchpadSensitivity,
                    scrollSensitivity: scrollSensitivity,
                    invertScroll: invertScroll,
                    onMove: { dx, dy, isDragging in
                        var buttons = activeButtons
                        if isDragging {
                            buttons.insert(.left)
                        }
                        hid.sendMouse(MouseReport(buttons: buttons, dX: dx, dY: dy))
                    },
                    onScroll: { hid.scroll($0) },
                    onLeftClick: { Haptics.tap(); hid.click(.left) },
                    onRightClick: { Haptics.tap(); hid.click(.right) },
                    onDragEnd: {
                        hid.sendMouse(MouseReport(buttons: activeButtons))
                    },
                    onGestureAction: { action in
                        action.execute(hid: hid)
                    },
                    onZoom: { delta in
                        handlePinchZoom(delta: delta)
                    }
                )
            #endif
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        #if os(macOS)
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let dx = HIDInput.clamp((value.translation.width - dragOffset.width) * touchpadSensitivity)
                        let dy = HIDInput.clamp((value.translation.height - dragOffset.height) * touchpadSensitivity)
                        dragOffset = value.translation
                        hid.sendMouse(MouseReport(buttons: activeButtons, dX: dx, dY: dy))
                    }
                    .onEnded { _ in
                        dragOffset = .zero
                        hid.sendMouse(MouseReport(buttons: activeButtons))
                    }
            )
        #endif
    }

    private func handlePinchZoom(delta: CGFloat) {
        let action = TrackpadGestureAction(rawValue: pinchActionRaw) ?? .zoom
        if action == .zoom {
            let wheelDelta: Int8 = delta > 0 ? 1 : -1
            hid.sendMouse(MouseReport(wheel: wheelDelta))
            hid.sendMouse(.zero)
        } else {
            action.execute(hid: hid)
        }
    }

    private var scrollAmount: Int8 {
        max(1, HIDInput.clamp(CGFloat(3 * scrollSensitivity)))
    }

    private var scrollColumn: some View {
        VStack(spacing: cellGap) {
            scrollButton("arrow.up", L10n.Mouse.wheelUp, scrollAmount)
            scrollButton("arrow.down", L10n.Mouse.wheelDown, -scrollAmount)
        }
    }

    private var mouseButtonsRow: some View {
        HStack(spacing: cellGap) {
            mouseButton(.left, L10n.Mouse.leftButton)
            mouseButton(.middle, L10n.Mouse.middleButton)
            mouseButton(.right, L10n.Mouse.rightButton)
        }
    }

    private func mouseButton(_ button: MouseButtons, _ label: LocalizedStringKey) -> some View {
        HoldButton(
            onPress: {
                activeButtons.insert(button)
                hid.sendMouse(MouseReport(buttons: activeButtons))
            },
            onRelease: {
                activeButtons.remove(button)
                hid.sendMouse(MouseReport(buttons: activeButtons))
            },
            background: { RoundedRectangle(cornerRadius: 12).fill(groupFill) },
            label: { Color.clear }
        )
        .accessibilityLabel(label)
    }

    private func scrollButton(_ icon: String, _ label: LocalizedStringKey, _ wheel: Int8) -> some View {
        HoldButton(
            onPress: { hid.scroll(wheel) },
            onRelease: {},
            background: { RoundedRectangle(cornerRadius: 12).fill(groupFill) },
            label: { Image(systemName: icon).font(.body) }
        )
        .accessibilityLabel(label)
    }
}
