#if os(iOS)
    import SwiftUI
    import UIKit

    /// 1-finger drag: moves
    /// 1-finger double-tap drag: drags with left button down
    /// 1-finger tap: left-clicks
    /// 2-finger tap: right-clicks
    /// 2-finger drag: scrolls (supports direction inversion)
    /// 2-finger pinch: zoom or mapped action
    /// 3-finger swipe: up, down, left, right mapped actions
    /// 3-finger tap: mapped action
    struct TouchpadView: UIViewRepresentable {
        var moveSensitivity: CGFloat
        var scrollSensitivity: CGFloat
        var invertScroll: Bool
        var onMove: (_ dx: Int8, _ dy: Int8, _ isDragging: Bool) -> Void
        var onScroll: (Int8) -> Void
        var onLeftClick: () -> Void
        var onRightClick: () -> Void
        var onDragEnd: () -> Void
        var onGestureAction: (TrackpadGestureAction) -> Void
        var onZoom: (CGFloat) -> Void

        func makeCoordinator() -> Coordinator {
            Coordinator()
        }

        func makeUIView(context: Context) -> UIView {
            let view = UIView()
            view.backgroundColor = .clear
            view.isMultipleTouchEnabled = true
            let c = context.coordinator

            let move = UIPanGestureRecognizer(target: c, action: #selector(Coordinator.handleMove(_:)))
            move.minimumNumberOfTouches = 1
            move.maximumNumberOfTouches = 1
            move.delegate = c

            let scroll = UIPanGestureRecognizer(target: c, action: #selector(Coordinator.handleScroll(_:)))
            scroll.minimumNumberOfTouches = 2
            scroll.maximumNumberOfTouches = 2
            scroll.delegate = c

            let pinch = UIPinchGestureRecognizer(target: c, action: #selector(Coordinator.handlePinch(_:)))
            pinch.delegate = c

            let left = UITapGestureRecognizer(target: c, action: #selector(Coordinator.handleLeft))
            left.numberOfTouchesRequired = 1
            left.delegate = c

            let right = UITapGestureRecognizer(target: c, action: #selector(Coordinator.handleRight))
            right.numberOfTouchesRequired = 2
            right.delegate = c

            let threeTap = UITapGestureRecognizer(target: c, action: #selector(Coordinator.handleThreeFingerTap))
            threeTap.numberOfTouchesRequired = 3
            threeTap.delegate = c

            let swipeUp = UISwipeGestureRecognizer(target: c, action: #selector(Coordinator.handleSwipeUp))
            swipeUp.numberOfTouchesRequired = 3
            swipeUp.direction = .up
            swipeUp.delegate = c

            let swipeDown = UISwipeGestureRecognizer(target: c, action: #selector(Coordinator.handleSwipeDown))
            swipeDown.numberOfTouchesRequired = 3
            swipeDown.direction = .down
            swipeDown.delegate = c

            let swipeLeft = UISwipeGestureRecognizer(target: c, action: #selector(Coordinator.handleSwipeLeft))
            swipeLeft.numberOfTouchesRequired = 3
            swipeLeft.direction = .left
            swipeLeft.delegate = c

            let swipeRight = UISwipeGestureRecognizer(target: c, action: #selector(Coordinator.handleSwipeRight))
            swipeRight.numberOfTouchesRequired = 3
            swipeRight.direction = .right
            swipeRight.delegate = c

            [move, scroll, pinch, left, right, threeTap, swipeUp, swipeDown, swipeLeft, swipeRight]
                .forEach { view.addGestureRecognizer($0) }

            return view
        }

        func updateUIView(_ uiView: UIView, context: Context) {
            let c = context.coordinator
            c.moveSensitivity = moveSensitivity
            c.scrollSensitivity = scrollSensitivity
            c.invertScroll = invertScroll
            c.onMove = onMove
            c.onScroll = onScroll
            c.onLeftClick = onLeftClick
            c.onRightClick = onRightClick
            c.onDragEnd = onDragEnd
            c.onGestureAction = onGestureAction
            c.onZoom = onZoom
        }

        @MainActor
        final class Coordinator: NSObject, UIGestureRecognizerDelegate {
            var moveSensitivity: CGFloat = 1
            var scrollSensitivity: CGFloat = 1
            var invertScroll = false
            var onMove: (Int8, Int8, Bool) -> Void = { _, _, _ in }
            var onScroll: (Int8) -> Void = { _ in }
            var onLeftClick: () -> Void = {}
            var onRightClick: () -> Void = {}
            var onDragEnd: () -> Void = {}
            var onGestureAction: (TrackpadGestureAction) -> Void = { _ in }
            var onZoom: (CGFloat) -> Void = { _ in }

            private var scrollAccumulator: CGFloat = 0
            private let scrollStep: CGFloat = 6

            private var lastTapTime: TimeInterval = 0
            private var isDragging = false

            @objc func handleMove(_ pan: UIPanGestureRecognizer) {
                guard let view = pan.view else { return }
                switch pan.state {
                case .began:
                    let now = CACurrentMediaTime()
                    if now - lastTapTime < 0.35 {
                        isDragging = true
                        lastTapTime = 0
                        Haptics.tap()
                        onMove(0, 0, true)
                    }
                case .changed:
                    let t = pan.translation(in: view)
                    let dx = HIDInput.clamp(t.x * moveSensitivity)
                    let dy = HIDInput.clamp(t.y * moveSensitivity)
                    if dx != 0 || dy != 0 {
                        onMove(dx, dy, isDragging)
                        pan.setTranslation(.zero, in: view)
                    }
                case .ended, .cancelled:
                    if isDragging {
                        isDragging = false
                        onDragEnd()
                    }
                default:
                    break
                }
            }

            @objc func handleScroll(_ pan: UIPanGestureRecognizer) {
                guard let view = pan.view else { return }
                if pan.state == .began { scrollAccumulator = 0 }
                scrollAccumulator += pan.translation(in: view).y
                pan.setTranslation(.zero, in: view)
                let step = scrollStep / max(scrollSensitivity, 0.1)
                while abs(scrollAccumulator) >= step {
                    let baseWheel: Int8 = scrollAccumulator > 0 ? -1 : 1
                    let finalWheel: Int8 = invertScroll ? -baseWheel : baseWheel
                    onScroll(finalWheel)
                    scrollAccumulator -= scrollAccumulator > 0 ? step : -step
                }
            }

            @objc func handlePinch(_ pinch: UIPinchGestureRecognizer) {
                if pinch.state == .changed {
                    let delta = pinch.scale - 1.0
                    if abs(delta) > 0.08 {
                        onZoom(delta)
                        pinch.scale = 1.0
                    }
                }
            }

            @objc func handleLeft() {
                lastTapTime = CACurrentMediaTime()
                onLeftClick()
            }

            @objc func handleRight() {
                lastTapTime = 0
                isDragging = false
                onRightClick()
            }

            @objc func handleThreeFingerTap() {
                Haptics.tap()
                let raw = UserDefaults.standard.string(forKey: AppSettings.threeFingerTapKey)
                    ?? TrackpadGestureAction.spotlight.rawValue
                if let action = TrackpadGestureAction(rawValue: raw) {
                    onGestureAction(action)
                }
            }

            @objc func handleSwipeUp() {
                Haptics.tap()
                let raw = UserDefaults.standard.string(forKey: AppSettings.threeFingerSwipeUpKey)
                    ?? TrackpadGestureAction.appSwitcher.rawValue
                if let action = TrackpadGestureAction(rawValue: raw) {
                    onGestureAction(action)
                }
            }

            @objc func handleSwipeDown() {
                Haptics.tap()
                let raw = UserDefaults.standard.string(forKey: AppSettings.threeFingerSwipeDownKey)
                    ?? TrackpadGestureAction.home.rawValue
                if let action = TrackpadGestureAction(rawValue: raw) {
                    onGestureAction(action)
                }
            }

            @objc func handleSwipeLeft() {
                Haptics.tap()
                let raw = UserDefaults.standard.string(forKey: AppSettings.threeFingerSwipeLeftKey)
                    ?? TrackpadGestureAction.previousApp.rawValue
                if let action = TrackpadGestureAction(rawValue: raw) {
                    onGestureAction(action)
                }
            }

            @objc func handleSwipeRight() {
                Haptics.tap()
                let raw = UserDefaults.standard.string(forKey: AppSettings.threeFingerSwipeRightKey)
                    ?? TrackpadGestureAction.nextApp.rawValue
                if let action = TrackpadGestureAction(rawValue: raw) {
                    onGestureAction(action)
                }
            }

            nonisolated func gestureRecognizer(
                _ gestureRecognizer: UIGestureRecognizer,
                shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer
            ) -> Bool {
                true
            }
        }
    }
#endif
