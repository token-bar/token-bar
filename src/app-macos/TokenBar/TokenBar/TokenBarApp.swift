import SwiftUI

@main
struct TokenBarApp: App {
    @NSApplicationDelegateAdaptor(TokenBarAppDelegate.self) private var appDelegate
    @Bindable private var store = AppEnvironment.shared

    var body: some Scene {
        WindowGroup(id: "coordinator") {
            AppCoordinatorView(store: store)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 1, height: 1)
        .windowStyle(.hiddenTitleBar)

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
