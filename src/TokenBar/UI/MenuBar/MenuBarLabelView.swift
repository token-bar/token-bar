import SwiftUI

struct MenuBarLabelView: View {
    let store: UsageStore

    var body: some View {
        Text(store.menuBarLabel)
    }
}
