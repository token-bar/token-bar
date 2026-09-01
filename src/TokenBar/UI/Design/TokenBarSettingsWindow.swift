import AppKit
import SwiftUI

extension Notification.Name {
    static let openTokenBarSettings = Notification.Name("TokenBarSettings.open")
}

/// Opens the settings `Window` scene from AppKit callbacks that lack SwiftUI environment access.
struct SettingsWindowOpener: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Color.clear
            .frame(width: 0, height: 0)
            .onReceive(NotificationCenter.default.publisher(for: .openTokenBarSettings)) { _ in
                TokenBarAppActivation.prepareForSettingsPresentation()
                openWindow(id: "settings")
            }
    }
}

/// Configures the Settings `NSWindow`: centers on first open, transparent title bar, clear background.
struct TokenBarSettingsWindowConfigurator: NSViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        DispatchQueue.main.async {
            configure(window: view.window, coordinator: context.coordinator)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            configure(window: nsView.window, coordinator: context.coordinator)
        }
    }

    private func configure(window: NSWindow?, coordinator: Coordinator) {
        guard let window else { return }

        window.title = "TokenBar Settings"
        window.titlebarAppearsTransparent = true
        window.backgroundColor = .clear
        window.isOpaque = false
        window.isMovableByWindowBackground = true
        window.styleMask.insert(.fullSizeContentView)
        window.appearance = nil

        guard !coordinator.didConfigure else {
            TokenBarAppActivation.settingsWindowDidAppear(window)
            return
        }
        coordinator.didConfigure = true
        window.center()
        TokenBarAppActivation.settingsWindowDidAppear(window)
    }

    final class Coordinator {
        var didConfigure = false
    }
}
