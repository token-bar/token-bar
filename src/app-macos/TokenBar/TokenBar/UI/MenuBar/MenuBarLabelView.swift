import SwiftUI

struct MenuBarLabelView: View {
    let store: UsageStore

    var body: some View {
        MenuBarStyledLabelView(
            displayMode: store.displayMode,
            providerDisplay: store.menuBarProviderDisplay,
            labelText: store.menuBarLabel,
            snapshot: store.activeSnapshot,
            forecast: store.activeForecast,
            aggregateItems: store.menuBarAggregateItems,
            rendersForMenuBar: true
        )
    }
}
