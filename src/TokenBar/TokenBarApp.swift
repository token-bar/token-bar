import SwiftUI

@main
struct TokenBarApp: App {
    @NSApplicationDelegateAdaptor(TokenBarAppDelegate.self) private var appDelegate

    private let store = AppEnvironment.shared

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(store: store)
                .background { SettingsWindowOpener() }
                .task { await store.bootstrap() }
        } label: {
            MenuBarLabelView(store: store)
        }
        .menuBarExtraStyle(.window)

        Window("TokenBar Settings", id: "settings") {
            SettingsView(store: store)
        }
        .windowResizability(.contentSize)
        .defaultSize(
            width: TokenBarMetrics.settingsWindowWidth,
            height: TokenBarMetrics.settingsWindowHeight
        )
        .defaultLaunchBehavior(.suppressed)
    }
}
