import SwiftUI

@available(macOS 14.0, *)
struct SettingsView: View {
    let store: UsageStore

    var body: some View {
        NavigationSplitView {
            List(SettingsSection.allCases, selection: $selectedSection) { section in
                Label(section.title, systemImage: section.icon)
                    .tag(section)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        } detail: {
            detailView(for: selectedSection)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding()
        }
        .frame(minWidth: 560, minHeight: 400)
    }

    @State private var selectedSection: SettingsSection = .display

    @ViewBuilder
    private func detailView(for section: SettingsSection) -> some View {
        switch section {
        case .providers:
            providersSection
        case .display:
            displaySection
        case .refresh:
            refreshSection
        case .notifications:
            notificationsSection
        }
    }

    private var providersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Providers")
                .font(.title2.weight(.semibold))
            Text("Add, remove, and reconnect providers. Coming in a later phase.")
                .foregroundStyle(.secondary)
            if store.accounts.isEmpty {
                Text("No providers registered.")
            } else {
                ForEach(store.accounts) { account in
                    HStack {
                        Text(account.displayName)
                        Spacer()
                        Text(account.isConnected ? "Connected" : "Disconnected")
                            .foregroundStyle(account.isConnected ? .green : .secondary)
                    }
                }
            }
        }
    }

    private var displaySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Display")
                .font(.title2.weight(.semibold))
            Picker("Menu bar style", selection: Binding(
                get: { store.displayMode },
                set: { store.displayMode = $0 }
            )) {
                ForEach(DisplayMode.allCases) { mode in
                    Text(mode.label).tag(mode)
                }
            }
            .pickerStyle(.radioGroup)
            Text("Preview: \(store.menuBarLabel)")
                .font(.body.monospaced())
                .padding(.top, 8)
        }
    }

    private var refreshSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Refresh")
                .font(.title2.weight(.semibold))
            Text("Automatic refresh intervals coming in a later phase.")
                .foregroundStyle(.secondary)
            Button("Refresh Now") {
                Task { await store.refresh() }
            }
            .disabled(store.isRefreshing)
        }
    }

    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notifications")
                .font(.title2.weight(.semibold))
            Text("Threshold alerts at 50%, 75%, 90%, and 100% coming in Phase 5.")
                .foregroundStyle(.secondary)
        }
    }
}

private enum SettingsSection: String, CaseIterable, Identifiable, Hashable {
    case providers
    case display
    case refresh
    case notifications

    var id: String { rawValue }

    var title: String {
        switch self {
        case .providers: "Providers"
        case .display: "Display"
        case .refresh: "Refresh"
        case .notifications: "Notifications"
        }
    }

    var icon: String {
        switch self {
        case .providers: "server.rack"
        case .display: "menubar.rectangle"
        case .refresh: "arrow.clockwise"
        case .notifications: "bell"
        }
    }
}
