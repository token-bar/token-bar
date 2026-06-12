import SwiftUI

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
        case .advanced:
            AdvancedProvidersView(store: store)
        case .display:
            displaySection
        case .refresh:
            refreshSection
        case .notifications:
            notificationsSection
        }
    }

    private var providersSection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Providers")
                    .font(.title2.weight(.semibold))

                Group {
                    Text("Connected")
                        .font(.headline)
                    if store.accounts.isEmpty {
                        Text("No providers connected.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(store.accounts) { account in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(account.displayName)
                                Text(account.connectionStatus.label)
                                    .font(.caption)
                                    .foregroundStyle(account.connectionStatus == .connected ? .green : .orange)
                                }
                                Spacer()
                                if account.isConnected {
                                    Button("Disconnect") {
                                        Task { await store.disconnectProvider(providerID: account.providerID) }
                                    }
                                } else {
                                    Button("Reconnect") {
                                        Task { await store.connectProvider(providerID: account.providerID) }
                                    }
                                }
                                Button("Remove", role: .destructive) {
                                    Task { await store.removeProvider(providerID: account.providerID) }
                                }
                            }
                        }
                    }
                }

                Group {
                    Text("Available")
                        .font(.headline)
                    if store.availableProviders.isEmpty {
                        Text("No provider types registered.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(store.availableProviders) { provider in
                            ProviderConnectionForm(provider: provider, store: store)
                            Divider()
                        }
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
    case advanced
    case display
    case refresh
    case notifications

    var id: String { rawValue }

    var title: String {
        switch self {
        case .providers: "Providers"
        case .advanced: "Advanced"
        case .display: "Display"
        case .refresh: "Refresh"
        case .notifications: "Notifications"
        }
    }

    var icon: String {
        switch self {
        case .providers: "server.rack"
        case .advanced: "wrench.and.screwdriver"
        case .display: "menubar.rectangle"
        case .refresh: "arrow.clockwise"
        case .notifications: "bell"
        }
    }
}
