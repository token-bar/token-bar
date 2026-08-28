import SwiftUI

struct SettingsView: View {
    let store: UsageStore

    @State private var selectedSection: SettingsSection = .general
    @State private var expandedConnectedProviderIDs: Set<String> = []
    @State private var expandedAvailableProviderIDs: Set<String> = []
    @State private var expandedAdvancedProviderIDs: Set<String> = []

    var body: some View {
        ZStack {
            TokenBarWindowBackdrop()

            TokenBarGlassPanel(style: .settings) {
                VStack(alignment: .leading, spacing: TokenBarMetrics.spacing) {
                    TokenBarPanelTitle(title: "Settings")

                    HStack(alignment: .top, spacing: TokenBarMetrics.spacing) {
                        sectionSidebar
                        TokenBarPanelDivider()
                            .frame(maxHeight: .infinity)
                        TokenBarSettingsScrollView {
                            detailView(for: selectedSection)
                        }
                    }
                }
            }
            .padding(TokenBarMetrics.windowPadding)
        }
        .frame(
            minWidth: TokenBarMetrics.settingsPanelMinWidth + TokenBarMetrics.windowPadding * 2,
            minHeight: TokenBarMetrics.settingsPanelMinHeight + TokenBarMetrics.windowPadding * 2
        )
    }

    private var sectionSidebar: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(SettingsSection.allCases) { section in
                TokenBarSettingsNavItem(
                    section: section,
                    isSelected: selectedSection == section
                ) {
                    selectedSection = section
                }
            }
        }
        .frame(width: TokenBarMetrics.settingsNavWidth, alignment: .leading)
    }

    @ViewBuilder
    private func detailView(for section: SettingsSection) -> some View {
        switch section {
        case .general:
            GeneralSettingsView(store: store)
        case .providers:
            providersSection
        case .advanced:
            AdvancedProvidersView(
                store: store,
                expandedProviderIDs: $expandedAdvancedProviderIDs
            )
        case .display:
            displaySection
        case .refresh:
            refreshSection
        case .notifications:
            notificationsSection
        }
    }

    private var providersSection: some View {
        VStack(alignment: .leading, spacing: TokenBarMetrics.spacing) {
            TokenBarPanelTitle(title: "Providers")

            if store.accounts.count > 1 {
                VStack(alignment: .leading, spacing: TokenBarMetrics.innerSpacing) {
                    TokenBarSectionHeader(title: "Default provider")
                    Picker("Menu bar provider", selection: activeAccountBinding) {
                        ForEach(store.accounts) { account in
                            Text(account.displayName).tag(Optional(account.id))
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                }
            }

            VStack(alignment: .leading, spacing: TokenBarMetrics.innerSpacing) {
                TokenBarSectionHeader(title: "Connected")
                if store.accounts.isEmpty {
                    Text("No providers connected.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(store.accounts) { account in
                        TokenBarConnectedProviderAccordion(
                            account: account,
                            store: store,
                            isExpanded: expandedConnectedProviderIDs.contains(account.providerID),
                            onToggle: { toggleConnectedAccordion(account.providerID) }
                        )
                    }
                }
            }

            VStack(alignment: .leading, spacing: TokenBarMetrics.innerSpacing) {
                TokenBarSectionHeader(title: "Available")
                if store.availableProviders.isEmpty {
                    Text("No provider types registered.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(store.availableProviders) { provider in
                        TokenBarProviderAccordion(
                            provider: provider,
                            store: store,
                            isExpanded: expandedAvailableProviderIDs.contains(provider.id),
                            onToggle: { toggleAvailableAccordion(provider.id) }
                        )
                    }
                }
            }
        }
    }

    private var displaySection: some View {
        VStack(alignment: .leading, spacing: TokenBarMetrics.spacing) {
            TokenBarPanelTitle(title: "Display")
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
            TokenBarGlassCard {
                Text("Preview: \(store.menuBarLabel)")
                    .font(.body.monospaced())
            }
        }
    }

    private var refreshSection: some View {
        VStack(alignment: .leading, spacing: TokenBarMetrics.spacing) {
            TokenBarPanelTitle(title: "Refresh")
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
            .buttonStyle(.glassProminent)
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
        VStack(alignment: .leading, spacing: TokenBarMetrics.spacing) {
            TokenBarPanelTitle(title: "Notifications")

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
                TokenBarSectionHeader(title: "Recent alerts")
                ForEach(store.alerts.prefix(10)) { alert in
                    if let account = store.accounts.first(where: { $0.id == alert.accountID }) {
                        TokenBarGlassCard {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(account.displayName): \(alert.summary)")
                                Text(alert.triggeredAt.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
    }

    private func toggleConnectedAccordion(_ providerID: String) {
        toggleProviderID(providerID, in: &expandedConnectedProviderIDs)
    }

    private func toggleAvailableAccordion(_ providerID: String) {
        toggleProviderID(providerID, in: &expandedAvailableProviderIDs)
    }

    private func toggleProviderID(_ providerID: String, in set: inout Set<String>) {
        if set.contains(providerID) {
            set.remove(providerID)
        } else {
            set.insert(providerID)
        }
    }
}
