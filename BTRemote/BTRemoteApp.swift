import SwiftUI

#if os(macOS)
    enum TransportMode: String, CaseIterable, Codable {
        case classic
        case lowEnergy

        static let defaultMode: TransportMode = .lowEnergy
    }
#endif

@main
struct BTRemoteApp: App {
    #if os(iOS)
        @StateObject private var lowEnergy = HIDPeripheral()
        @StateObject private var central = HIDCentral()
        @AppStorage(AppSettings.autoAdvertiseKey) private var autoAdvertise = true
    #else
        @StateObject private var lowEnergy = HIDPeripheral()
        @StateObject private var central = HIDCentral()
        @StateObject private var classic = HIDClassicDevice()
        @AppStorage("BTRemote.macTransportMode") private var modeRaw: String = TransportMode.defaultMode.rawValue
    #endif

    @StateObject private var deviceNames = DeviceNameStore()
    @AppStorage(AppSettings.colorSchemeKey) private var selectedTheme = "system"

    private var preferredColorScheme: ColorScheme? {
        switch selectedTheme {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    init() {
        UserDefaults.standard.register(defaults: [AppSettings.useServiceChangedKey: true])
    }

    private var hid: HIDInput {
        #if os(macOS)
            return HIDInput.make(lowEnergy: lowEnergy, central: central, classic: classic, classicMode: currentMode == .classic)
        #else
            return HIDInput.make(lowEnergy: lowEnergy, central: central)
        #endif
    }

    var body: some Scene {
        WindowGroup {
            #if os(iOS)
                ContentView()
                    .environmentObject(lowEnergy)
                    .environmentObject(central)
                    .environmentObject(deviceNames)
                    .environment(\.hid, hid)
                    .preferredColorScheme(preferredColorScheme)
                    .onAppear {
                        central.start()
                        if autoAdvertise { lowEnergy.start() }
                    }
            #else
                ContentView()
                    .environmentObject(lowEnergy)
                    .environmentObject(central)
                    .environmentObject(classic)
                    .environmentObject(deviceNames)
                    .environment(\.macTransport, currentMode)
                    .environment(\.hid, hid)
                    .preferredColorScheme(preferredColorScheme)
                    .onAppear { _onAppear() }
                    .onChange(of: modeRaw) { _ in _modeChanged() }
            #endif
        }
    }

    #if os(macOS)
        private var currentMode: TransportMode {
            TransportMode(rawValue: modeRaw) ?? .defaultMode
        }

        private func _onAppear() {
            switch currentMode {
            case .classic:
                classic.start()
            case .lowEnergy:
                lowEnergy.start()
                central.start()
            }
        }

        private func _modeChanged() {
            // tear down the previously-active backend to prevent race
            lowEnergy.stop()
            classic.stop()

            switch currentMode {
            case .classic:
                classic.start()
            case .lowEnergy:
                lowEnergy.start()
                central.start()
            }
        }
    #endif
}

#if os(macOS)
    private struct MacTransportKey: EnvironmentKey {
        static let defaultValue: TransportMode = .defaultMode
    }

    extension EnvironmentValues {
        var macTransport: TransportMode {
            get { self[MacTransportKey.self] }
            set { self[MacTransportKey.self] = newValue }
        }
    }
#endif
