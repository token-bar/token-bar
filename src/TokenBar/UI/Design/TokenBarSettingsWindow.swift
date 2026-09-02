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
        let view = SettingsWindowAnchorView()
        view.coordinator = context.coordinator
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        (nsView as? SettingsWindowAnchorView)?.coordinator = context.coordinator
    }

    final class Coordinator {
        private var configuredWindowIDs = Set<ObjectIdentifier>()

        @MainActor
        func configureWindowIfNeeded(_ window: NSWindow) {
            let windowID = ObjectIdentifier(window)
            guard !configuredWindowIDs.contains(windowID) else { return }
            configuredWindowIDs.insert(windowID)

            window.title = "TokenBar Settings"
            window.titlebarAppearsTransparent = true
            window.backgroundColor = .clear
            window.isOpaque = false
            window.isMovableByWindowBackground = true
            window.styleMask.insert(.fullSizeContentView)
            window.appearance = nil
            window.center()
        }
    }
}

/// Applies window chrome when attached to the settings window, outside SwiftUI's layout pass.
private final class SettingsWindowAnchorView: NSView {
    weak var coordinator: TokenBarSettingsWindowConfigurator.Coordinator?

    override var isFlipped: Bool { true }

    override var intrinsicContentSize: NSSize { .zero }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        guard let window, let coordinator else { return }
        Task { @MainActor in
            coordinator.configureWindowIfNeeded(window)
        }
    }
}
