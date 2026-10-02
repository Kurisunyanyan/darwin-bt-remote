#if os(iOS)
    import SwiftUI
    import UIKit

    /// 1-finger drag: moves
    /// 1-finger double-tap drag: drags with left button down (if enabled)
    /// 1-finger tap: left-clicks
    /// 2-finger tap: right-clicks
    /// 2-finger drag: scrolls (supports direction inversion)
    /// 2-finger pinch: zoom (in/out)
    /// 2-finger rotation: rotate gesture
    /// 3-finger swipe: up, down, left, right mapped actions
    /// 3-finger tap: mapped action
    /// 4-finger swipe: up, down, left, right mapped actions
    /// 4-finger tap: mapped action
    struct TouchpadView: UIViewRepresentable {
        var moveSensitivity: CGFloat
        var scrollSensitivity: CGFloat
        var invertScroll: Bool
        var doubleTapDragEnabled: Bool
        var onMove: (_ dx: Int8, _ dy: Int8, _ isDragging: Bool) -> Void
        var onScroll: (Int8) -> Void
        var onLeftClick: () -> Void
        var onRightClick: () -> Void
        var onDragEnd: () -> Void
        var onGestureAction: (TrackpadGestureAction) -> Void
        var onZoom: (CGFloat) -> Void
        var onRotate: (CGFloat) -> Void

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

            let rotation = UIRotationGestureRecognizer(target: c, action: #selector(Coordinator.handleRotation(_:)))
            rotation.delegate = c

            let left = UITapGestureRecognizer(target: c, action: #selector(Coordinator.handleLeft(_:)))
            left.numberOfTouchesRequired = 1
            left.delegate = c

            let right = UITapGestureRecognizer(target: c, action: #selector(Coordinator.handleRight))
            right.numberOfTouchesRequired = 2
            right.delegate = c

            let threeTap = UITapGestureRecognizer(target: c, action: #selector(Coordinator.handleThreeFingerTap))
            threeTap.numberOfTouchesRequired = 3
            threeTap.delegate = c

            let fourTap = UITapGestureRecognizer(target: c, action: #selector(Coordinator.handleFourFingerTap))
            fourTap.numberOfTouchesRequired = 4
            fourTap.delegate = c

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

            let fourSwipeUp = UISwipeGestureRecognizer(target: c, action: #selector(Coordinator.handleFourSwipeUp))
            fourSwipeUp.numberOfTouchesRequired = 4
            fourSwipeUp.direction = .up
            fourSwipeUp.delegate = c

            let fourSwipeDown = UISwipeGestureRecognizer(target: c, action: #selector(Coordinator.handleFourSwipeDown))
            fourSwipeDown.numberOfTouchesRequired = 4
            fourSwipeDown.direction = .down
            fourSwipeDown.delegate = c

            let fourSwipeLeft = UISwipeGestureRecognizer(target: c, action: #selector(Coordinator.handleFourSwipeLeft))
            fourSwipeLeft.numberOfTouchesRequired = 4
            fourSwipeLeft.direction = .left
            fourSwipeLeft.delegate = c

            let fourSwipeRight = UISwipeGestureRecognizer(target: c, action: #selector(Coordinator.handleFourSwipeRight))
            fourSwipeRight.numberOfTouchesRequired = 4
            fourSwipeRight.direction = .right
            fourSwipeRight.delegate = c

            c.scrollRecognizer = scroll
            c.pinchRecognizer = pinch
            c.rotationRecognizer = rotation

            [move, scroll, pinch, rotation, left, right, threeTap, fourTap,
             swipeUp, swipeDown, swipeLeft, swipeRight,
             fourSwipeUp, fourSwipeDown, fourSwipeLeft, fourSwipeRight]
                .forEach { view.addGestureRecognizer($0) }

            return view
        }

        func updateUIView(_ uiView: UIView, context: Context) {
            let c = context.coordinator
            c.moveSensitivity = moveSensitivity
            c.scrollSensitivity = scrollSensitivity
            c.invertScroll = invertScroll
            c.doubleTapDragEnabled = doubleTapDragEnabled
            c.onMove = onMove
            c.onScroll = onScroll
            c.onLeftClick = onLeftClick
            c.onRightClick = onRightClick
            c.onDragEnd = onDragEnd
            c.onGestureAction = onGestureAction
            c.onZoom = onZoom
            c.onRotate = onRotate
        }

        @MainActor
        final class Coordinator: NSObject, UIGestureRecognizerDelegate {
            var moveSensitivity: CGFloat = 1
            var scrollSensitivity: CGFloat = 1
            var invertScroll = false
            var doubleTapDragEnabled = true
            var onMove: (Int8, Int8, Bool) -> Void = { _, _, _ in }
            var onScroll: (Int8) -> Void = { _ in }
            var onLeftClick: () -> Void = {}
            var onRightClick: () -> Void = {}
            var onDragEnd: () -> Void = {}
            var onGestureAction: (TrackpadGestureAction) -> Void = { _ in }
            var onZoom: (CGFloat) -> Void = { _ in }
            var onRotate: (CGFloat) -> Void = { _ in }

            weak var scrollRecognizer: UIPanGestureRecognizer?
            weak var pinchRecognizer: UIPinchGestureRecognizer?
            weak var rotationRecognizer: UIRotationGestureRecognizer?

            private var scrollAccumulator: CGFloat = 0
            private let scrollStep: CGFloat = 6

            private var lastTapTime: TimeInterval = 0
            private var lastTapLocation: CGPoint = .zero
            private var isDragging = false
            private var isPinching = false

            @objc func handleMove(_ pan: UIPanGestureRecognizer) {
                guard let view = pan.view else { return }
                switch pan.state {
                case .began:
                    if doubleTapDragEnabled {
                        let now = CACurrentMediaTime()
                        let loc = pan.location(in: view)
                        let dist = hypot(loc.x - lastTapLocation.x, loc.y - lastTapLocation.y)
                        if now - lastTapTime < 0.28 && dist < 30 {
                            isDragging = true
                            lastTapTime = 0
                            Haptics.tap()
                            onMove(0, 0, true)
                        }
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
                guard let view = pan.view, !isPinching else { return }
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
                switch pinch.state {
                case .began:
                    isPinching = true
                    scrollAccumulator = 0
                case .changed:
                    isPinching = true
                    let delta = pinch.scale - 1.0
                    if abs(delta) > 0.04 {
                        onZoom(delta)
                        pinch.scale = 1.0
                    }
                case .ended, .cancelled:
                    Task { @MainActor in
                        try? await Task.sleep(nanoseconds: 150_000_000)
                        self.isPinching = false
                    }
                default:
                    break
                }
            }

            @objc func handleRotation(_ rot: UIRotationGestureRecognizer) {
                switch rot.state {
                case .began:
                    isPinching = true
                case .changed:
                    isPinching = true
                    let delta = rot.rotation
                    if abs(delta) > 0.25 {
                        onRotate(delta)
                        rot.rotation = 0
                    }
                case .ended, .cancelled:
                    Task { @MainActor in
                        try? await Task.sleep(nanoseconds: 150_000_000)
                        self.isPinching = false
                    }
                default:
                    break
                }
            }

            @objc func handleLeft(_ tap: UITapGestureRecognizer) {
                guard let view = tap.view else { return }
                lastTapTime = CACurrentMediaTime()
                lastTapLocation = tap.location(in: view)
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

            @objc func handleFourFingerTap() {
                Haptics.tap()
                let raw = UserDefaults.standard.string(forKey: AppSettings.fourFingerTapKey)
                    ?? TrackpadGestureAction.controlCenter.rawValue
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

            @objc func handleFourSwipeUp() {
                Haptics.tap()
                let raw = UserDefaults.standard.string(forKey: AppSettings.fourFingerSwipeUpKey)
                    ?? TrackpadGestureAction.dock.rawValue
                if let action = TrackpadGestureAction(rawValue: raw) {
                    onGestureAction(action)
                }
            }

            @objc func handleFourSwipeDown() {
                Haptics.tap()
                let raw = UserDefaults.standard.string(forKey: AppSettings.fourFingerSwipeDownKey)
                    ?? TrackpadGestureAction.home.rawValue
                if let action = TrackpadGestureAction(rawValue: raw) {
                    onGestureAction(action)
                }
            }

            @objc func handleFourSwipeLeft() {
                Haptics.tap()
                let raw = UserDefaults.standard.string(forKey: AppSettings.fourFingerSwipeLeftKey)
                    ?? TrackpadGestureAction.previousApp.rawValue
                if let action = TrackpadGestureAction(rawValue: raw) {
                    onGestureAction(action)
                }
            }

            @objc func handleFourSwipeRight() {
                Haptics.tap()
                let raw = UserDefaults.standard.string(forKey: AppSettings.fourFingerSwipeRightKey)
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
