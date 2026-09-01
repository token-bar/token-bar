import AppKit

/// Manages activation policy for a menu-bar-only app (`LSUIElement`).
/// Settings must run as a regular app so the window comes to the front and
/// **TokenBar** appears in the system menu bar.
@MainActor
enum TokenBarAppActivation {
    private static var settingsCloseObserver: NSObjectProtocol?

    static func bootstrap() {
        NSApp.setActivationPolicy(.accessory)
    }

    static func prepareForSettingsPresentation() {
        if NSApp.activationPolicy() != .regular {
            NSApp.setActivationPolicy(.regular)
        }
        NSApp.activate(ignoringOtherApps: true)
    }

    static func settingsWindowDidAppear(_ window: NSWindow) {
        prepareForSettingsPresentation()
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()

        settingsCloseObserver.map { NotificationCenter.default.removeObserver($0) }
        settingsCloseObserver = NotificationCenter.default.addObserver(
            forName: NSWindow.willCloseNotification,
            object: window,
            queue: .main
        ) { _ in
            Task { @MainActor in
                settingsCloseObserver.map { NotificationCenter.default.removeObserver($0) }
                settingsCloseObserver = nil
                NSApp.setActivationPolicy(.accessory)
            }
        }
    }
}

@MainActor
final class TokenBarAppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        TokenBarAppActivation.bootstrap()
        #if os(macOS)
        ProviderBrandIconImage.installAppearanceObserverIfNeeded()
        #endif
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        guard !flag else { return true }
        NotificationCenter.default.post(name: .openTokenBarSettings, object: nil)
        return true
    }
}
