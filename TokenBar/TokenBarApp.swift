import SwiftUI

@main
struct TokenBarApp: App {
    var body: some Scene {
        MenuBarExtra("TokenBar", systemImage: "chart.bar") {
            MenuBarView()
        }

        Settings {
            SettingsPlaceholderView()
        }
    }
}
