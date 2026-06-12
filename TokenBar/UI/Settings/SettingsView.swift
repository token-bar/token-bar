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

                if store.accounts.count > 1 {
                    Group {
                        Text("Default provider")
                            .font(.headline)
                        Picker("Menu bar provider", selection: activeAccountBinding) {
                            ForEach(store.accounts) { account in
                                Text(account.displayName).tag(Optional(account.id))
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.menu)
                    }
                }

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
            if store.displayMode == .burnRate {
                Text("Burn rate requires usage history from automatic or manual refreshes.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text("Preview: \(store.menuBarLabel)")
                .font(.body.monospaced())
                .padding(.top, 8)
        }
    }

    private var refreshSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Refresh")
                .font(.title2.weight(.semibold))
            Picker("Automatic refresh", selection: Binding(
                get: { store.refreshInterval },
                set: { store.refreshInterval = $0 }
            )) {
                ForEach(RefreshInterval.allCases) { interval in
                    Text(interval.label).tag(interval)
                }
            }
            .pickerStyle(.radioGroup)
            if let lastRefresh = store.lastRefreshAt {
                Text("Last refresh: \(lastRefresh.formatted(date: .abbreviated, time: .shortened))")
                    .foregroundStyle(.secondary)
            }
            if let nextRefresh = store.nextRefreshAt {
                Text("Next refresh: \(nextRefresh.formatted(date: .abbreviated, time: .shortened))")
                    .foregroundStyle(.secondary)
            }
            Button("Refresh Now") {
                Task { await store.refresh() }
            }
            .disabled(store.isRefreshing)
        }
    }

    private var activeAccountBinding: Binding<UUID?> {
        Binding(
            get: { store.activeAccountID },
            set: { newValue in
                guard let newValue else { return }
                store.selectAccount(newValue)
            }
        )
    }

    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Notifications")
                .font(.title2.weight(.semibold))

            Toggle("Enable usage alerts", isOn: Binding(
                get: { store.notificationsEnabled },
                set: { store.notificationsEnabled = $0 }
            ))

            Text("Alerts fire when usage crosses 50%, 75%, 90%, or 100%, or when quota exhaustion is forecast within 7 days. Each alert is delivered once per billing cycle.")
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            if store.alerts.isEmpty {
                Text("No alerts yet.")
                    .foregroundStyle(.secondary)
            } else {
                Text("Recent alerts")
                    .font(.headline)
                ForEach(store.alerts.prefix(10)) { alert in
                    if let account = store.accounts.first(where: { $0.id == alert.accountID }) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(account.displayName): \(alert.summary)")
                                Text(alert.triggeredAt.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                    }
                }
            }
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
