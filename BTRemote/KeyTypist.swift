import Foundation
import SwiftUI

/// paces keyboard reports so each down/up transition is delivered;
/// without spacing, rapid identical key presses get coalesced and lost.
@MainActor
final class KeyTypist: ObservableObject {
    var send: ((KeyboardReport) -> Void)?

    private var queue: [KeyboardReport] = []
    private var draining = false

    func enqueue(_ reports: [KeyboardReport]) {
        guard !reports.isEmpty else { return }
        queue.append(contentsOf: reports)
        guard !draining else { return }
        draining = true
        Task { await drain() }
    }

    private func drain() async {
        while !queue.isEmpty {
            send?(queue.removeFirst())
            try? await Task.sleep(nanoseconds: 20_000_000)
        }
        draining = false
    }
}
