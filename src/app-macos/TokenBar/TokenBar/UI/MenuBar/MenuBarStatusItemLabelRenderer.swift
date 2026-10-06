import AppKit
import SwiftUI

@MainActor
enum MenuBarStatusItemLabelRenderer {
    static func apply(to button: NSStatusBarButton, store: UsageStore) {
        let labelView = MenuBarStyledLabelView(
            displayMode: store.displayMode,
            providerDisplay: store.menuBarProviderDisplay,
            labelText: store.menuBarLabel,
            snapshot: store.activeSnapshot,
            forecast: store.activeForecast,
            aggregateItems: store.menuBarAggregateItems,
            rendersForMenuBar: true
        )
        .padding(.horizontal, 2)

        let renderer = ImageRenderer(content: labelView)
        renderer.scale = button.window?.backingScaleFactor ?? NSScreen.main?.backingScaleFactor ?? 2

        if let image = renderer.nsImage {
            button.image = image
            button.imagePosition = .imageOnly
            button.title = ""
        } else {
            button.image = nil
            button.imagePosition = .noImage
            button.title = store.menuBarLabel
        }

        button.toolTip = store.menuBarLabel
    }
}
