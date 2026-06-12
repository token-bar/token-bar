import SwiftUI

@available(macOS 14.0, *)
struct MenuBarLabelView: View {
    let store: UsageStore

    var body: some View {
        Text(store.menuBarLabel)
    }
}
