import AppKit
import SwiftUI

@MainActor
final class MenuBarPanelController: NSObject, NSPopoverDelegate {
    private let popover = NSPopover()
    private let store: UsageStore
    private var hostingController: NSHostingController<AnyView>?

    init(store: UsageStore) {
        self.store = store
        super.init()
        popover.behavior = .transient
        popover.animates = true
        popover.delegate = self
    }

    func toggle(relativeTo button: NSStatusBarButton) {
        if popover.isShown {
            popover.performClose(nil)
            return
        }

        let root = AnyView(
            MenuBarView(store: store)
                .background { SettingsWindowOpener() }
        )
        let hosting = NSHostingController(rootView: root)
        hosting.sizingOptions = [.preferredContentSize]
        hostingController = hosting
        popover.contentViewController = hosting

        let fittingSize = hosting.sizeThatFits(
            in: NSSize(
                width: TokenBarMetrics.menuPanelWidth,
                height: CGFloat.greatestFiniteMagnitude
            )
        )
        popover.contentSize = NSSize(
            width: max(TokenBarMetrics.menuPanelWidth, fittingSize.width),
            height: fittingSize.height
        )
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
    }

    func closeIfNeeded() {
        guard popover.isShown else { return }
        popover.performClose(nil)
    }
}
