import AppKit
import SwiftUI

@MainActor
final class MenuBarStatusItemController: NSObject {
    private let store: UsageStore
    private let panelController: MenuBarPanelController
    private var statusItem: NSStatusItem?
    private var contextMenu: NSMenu?
    private var appearanceObserver: NSObjectProtocol?

    init(store: UsageStore) {
        self.store = store
        self.panelController = MenuBarPanelController(store: store)
        super.init()
    }

    func install() {
        guard statusItem == nil else { return }

        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem = item

        guard let button = item.button else { return }
        button.target = self
        button.action = #selector(handleStatusItemClick(_:))
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])

        contextMenu = makeContextMenu()
        installAppearanceObserver()
        startObservingStore()
        refreshLabel()

        Task { await store.bootstrap() }
    }

    func refreshLabel() {
        guard let button = statusItem?.button else { return }
        MenuBarStatusItemLabelRenderer.apply(to: button, store: store)
    }

    @objc private func handleStatusItemClick(_ sender: Any?) {
        guard let button = statusItem?.button else { return }
        guard let event = NSApp.currentEvent else { return }

        if event.type == .rightMouseUp {
            if let menu = contextMenu {
                menu.popUp(
                    positioning: nil,
                    at: NSPoint(x: 0, y: button.bounds.height + 4),
                    in: button
                )
            }
            return
        }

        panelController.toggle(relativeTo: button)
    }

    @objc private func openSettings() {
        NotificationCenter.default.post(name: .openTokenBarSettings, object: nil)
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }

    private func makeContextMenu() -> NSMenu {
        let menu = NSMenu()

        let settingsItem = NSMenuItem(
            title: "Open Settings…",
            action: #selector(openSettings),
            keyEquivalent: ""
        )
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(
            title: "Quit TokenBar",
            action: #selector(quit),
            keyEquivalent: "q"
        )
        quitItem.keyEquivalentModifierMask = [.command]
        quitItem.target = self
        menu.addItem(quitItem)

        return menu
    }

    private func startObservingStore() {
        withObservationTracking {
            _ = store.menuBarPresentationToken
            _ = store.displayMode
            _ = store.menuBarProviderDisplay
            _ = store.snapshots.count
        } onChange: {
            Task { @MainActor in
                self.refreshLabel()
                self.startObservingStore()
            }
        }
    }

    private func installAppearanceObserver() {
        guard appearanceObserver == nil else { return }
        appearanceObserver = NotificationCenter.default.addObserver(
            forName: .init("AppleInterfaceThemeChangedNotification"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.refreshLabel()
            }
        }
    }
}
