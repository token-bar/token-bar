import AppKit
import SwiftUI

/// Hosts `SettingsWindowOpener` so AppKit callbacks can open the settings scene.
struct AppCoordinatorView: View {
    let store: UsageStore

    var body: some View {
        Color.clear
            .frame(width: 0, height: 0)
            .background { SettingsWindowOpener() }
            .onAppear(perform: hideCoordinatorWindow)
    }

    private func hideCoordinatorWindow() {
        DispatchQueue.main.async {
            for window in NSApp.windows where window.title != "TokenBar Settings" {
                let size = window.frame.size
                guard size.width <= 2, size.height <= 2 else { continue }
                window.setIsVisible(false)
                window.orderOut(nil)
                return
            }
        }
    }
}
