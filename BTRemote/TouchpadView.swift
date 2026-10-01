#if os(iOS)
    import SwiftUI
    import UIKit

    /// 1-finger drag: moves
    /// 1-finger double-tap drag: drags with left button down
    /// 1-finger tap: left-clicks
    /// 2-finger tap: right-clicks
    /// 2-finger drag: scrolls
    /// Precision Touchpad mode: reports multi-touch digitizer coordinates
    struct TouchpadView: UIViewRepresentable {
        var precisionMode: Bool
        var naturalScroll: Bool
        var moveSensitivity: CGFloat
        var scrollSensitivity: CGFloat
        var onMove: (_ dx: Int8, _ dy: Int8, _ isDragging: Bool) -> Void
        var onScroll: (Int8) -> Void
        var onLeftClick: () -> Void
        var onRightClick: () -> Void
        var onDragEnd: () -> Void
        var onDigitizer: (DigitizerReport) -> Void

        func makeCoordinator() -> Coordinator {
            Coordinator()
        }

        func makeUIView(context: Context) -> TouchpadCanvasView {
            let view = TouchpadCanvasView()
            view.backgroundColor = .clear
            view.isMultipleTouchEnabled = true
            let c = context.coordinator
            c.canvasView = view

            let move = UIPanGestureRecognizer(target: c, action: #selector(Coordinator.handleMove(_:)))
            move.minimumNumberOfTouches = 1
            move.maximumNumberOfTouches = 1
            move.delegate = c

            let scroll = UIPanGestureRecognizer(target: c, action: #selector(Coordinator.handleScroll(_:)))
            scroll.minimumNumberOfTouches = 2
            scroll.maximumNumberOfTouches = 2
            scroll.delegate = c

            let left = UITapGestureRecognizer(target: c, action: #selector(Coordinator.handleLeft))
            left.numberOfTouchesRequired = 1
            left.delegate = c

            let right = UITapGestureRecognizer(target: c, action: #selector(Coordinator.handleRight))
            right.numberOfTouchesRequired = 2
            right.delegate = c

            c.moveRecognizer = move
            c.scrollRecognizer = scroll
            c.leftRecognizer = left
            c.rightRecognizer = right

            [move, scroll, left, right].forEach { view.addGestureRecognizer($0) }

            view.onTouchesUpdated = { [weak c] touches in
                c?.handlePrecisionTouches(touches)
            }

            return view
        }

        func updateUIView(_ uiView: TouchpadCanvasView, context: Context) {
            let c = context.coordinator
            c.precisionMode = precisionMode
            c.naturalScroll = naturalScroll
            c.moveSensitivity = moveSensitivity
            c.scrollSensitivity = scrollSensitivity
            c.onMove = onMove
            c.onScroll = onScroll
            c.onLeftClick = onLeftClick
            c.onRightClick = onRightClick
            c.onDragEnd = onDragEnd
            c.onDigitizer = onDigitizer
            c.updateRecognizerStates()
        }

        @MainActor
        final class Coordinator: NSObject, UIGestureRecognizerDelegate {
            weak var canvasView: TouchpadCanvasView?
            var precisionMode = false
            var naturalScroll = true
            var moveSensitivity: CGFloat = 1
            var scrollSensitivity: CGFloat = 1
            var onMove: (Int8, Int8, Bool) -> Void = { _, _, _ in }
            var onScroll: (Int8) -> Void = { _ in }
            var onLeftClick: () -> Void = {}
            var onRightClick: () -> Void = {}
            var onDragEnd: () -> Void = {}
            var onDigitizer: (DigitizerReport) -> Void = { _ in }

            weak var moveRecognizer: UIPanGestureRecognizer?
            weak var scrollRecognizer: UIPanGestureRecognizer?
            weak var leftRecognizer: UITapGestureRecognizer?
            weak var rightRecognizer: UITapGestureRecognizer?

            private var scrollAccumulator: CGFloat = 0
            private let scrollStep: CGFloat = 6

            private var lastTapTime: TimeInterval = 0
            private var isDragging = false

            func updateRecognizerStates() {
                let enableGestures = !precisionMode
                moveRecognizer?.isEnabled = enableGestures
                scrollRecognizer?.isEnabled = enableGestures
                leftRecognizer?.isEnabled = enableGestures
                rightRecognizer?.isEnabled = enableGestures
            }

            @objc func handleMove(_ pan: UIPanGestureRecognizer) {
                guard let view = pan.view, !precisionMode else { return }
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
                guard let view = pan.view, !precisionMode else { return }
                if pan.state == .began { scrollAccumulator = 0 }
                scrollAccumulator += pan.translation(in: view).y
                pan.setTranslation(.zero, in: view)
                let step = scrollStep / max(scrollSensitivity, 0.1)
                while abs(scrollAccumulator) >= step {
                    let baseWheel: Int8 = scrollAccumulator > 0 ? -1 : 1
                    let finalWheel: Int8 = naturalScroll ? -baseWheel : baseWheel
                    onScroll(finalWheel)
                    scrollAccumulator -= scrollAccumulator > 0 ? step : -step
                }
            }

            @objc func handleLeft() {
                guard !precisionMode else { return }
                lastTapTime = CACurrentMediaTime()
                onLeftClick()
            }

            @objc func handleRight() {
                guard !precisionMode else { return }
                lastTapTime = 0
                isDragging = false
                onRightClick()
            }

            func handlePrecisionTouches(_ allTouches: [UITouch]) {
                guard precisionMode, let view = canvasView else { return }
                let active = allTouches.filter { $0.phase != .ended && $0.phase != .cancelled }
                if active.isEmpty {
                    onDigitizer(.zero)
                    return
                }

                let bounds = view.bounds
                let width = max(bounds.width, 1)
                let height = max(bounds.height, 1)

                var report = DigitizerReport()
                report.contactCount = UInt8(min(active.count, 2))

                if let t1 = active.first {
                    let loc = t1.location(in: view)
                    var c1 = DigitizerContact()
                    c1.tipSwitch = (t1.phase == .began || t1.phase == .moved || t1.phase == .stationary)
                    c1.confidence = true
                    c1.id = 0
                    c1.x = UInt16(min(4095, max(0, loc.x / width * 4095)))
                    c1.y = UInt16(min(4095, max(0, loc.y / height * 4095)))
                    report.contact1 = c1
                }

                if active.count > 1 {
                    let t2 = active[1]
                    let loc = t2.location(in: view)
                    var c2 = DigitizerContact()
                    c2.tipSwitch = (t2.phase == .began || t2.phase == .moved || t2.phase == .stationary)
                    c2.confidence = true
                    c2.id = 1
                    c2.x = UInt16(min(4095, max(0, loc.x / width * 4095)))
                    c2.y = UInt16(min(4095, max(0, loc.y / height * 4095)))
                    report.contact2 = c2
                }

                onDigitizer(report)
            }

            nonisolated func gestureRecognizer(
                _ gestureRecognizer: UIGestureRecognizer,
                shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer
            ) -> Bool {
                true
            }
        }
    }

    final class TouchpadCanvasView: UIView {
        var onTouchesUpdated: (([UITouch]) -> Void)?

        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            super.touchesBegan(touches, with: event)
            if let all = event?.allTouches {
                onTouchesUpdated?(Array(all))
            }
        }

        override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
            super.touchesMoved(touches, with: event)
            if let all = event?.allTouches {
                onTouchesUpdated?(Array(all))
            }
        }

        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            super.touchesEnded(touches, with: event)
            if let all = event?.allTouches {
                onTouchesUpdated?(Array(all))
            }
        }

        override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
            super.touchesCancelled(touches, with: event)
            if let all = event?.allTouches {
                onTouchesUpdated?(Array(all))
            }
        }
    }
#endif
