import SwiftUI

struct StandaloneTrackpadView: View {
    let hid: HIDInput

    var body: some View {
        TrackpadPanel(hid: hid)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#if DEBUG
    #Preview {
        StandaloneTrackpadView(hid: .unavailable)
    }
#endif
