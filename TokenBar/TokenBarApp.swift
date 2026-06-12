import SwiftUI

@main
struct TokenBarApp: App {
    private let store = AppEnvironment.shared

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(store: store)
                .task { await store.bootstrap() }
        } label: {
            MenuBarLabelView(store: store)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView(store: store)
        }
    }
}
