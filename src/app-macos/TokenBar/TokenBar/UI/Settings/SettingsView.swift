import AppKit
import SwiftUI

struct SettingsView: View {
    let store: UsageStore

    @State private var selectedSection: SettingsSection = .general
    @State private var expandedConnectedProviderIDs: Set<String> = []
    @State private var expandedAvailableProviderIDs: Set<String> = []
    @State private var expandedAdvancedProviderIDs: Set<String> = []

    var body: some View {
        TokenBarGlassPanel(style: .settings) {
            HStack(alignment: .top, spacing: TokenBarMetrics.spacing) {
                sectionSidebar
                TokenBarPanelDivider()
                    .frame(maxHeight: .infinity)
                TokenBarSettingsScrollView {
                    detailView(for: selectedSection)
                }
            }
        }
        .frame(
            width: TokenBarMetrics.settingsWindowWidth,
            height: TokenBarMetrics.settingsWindowHeight
        )
        .background {
            TokenBarWindowBackdrop()
        }
        .background {
            TokenBarSettingsWindowConfigurator()
        }
        .onAppear(perform: presentSettingsWindow)
    }

    private func presentSettingsWindow() {
        guard let window = settingsWindow else { return }
        TokenBarAppActivation.settingsWindowDidAppear(window)
    }

    private var settingsWindow: NSWindow? {
        NSApp.windows.first { $0.title == "TokenBar Settings" }
    }

    private var sectionSidebar: some View {
        VStack(alignment: .leading, spacing: 8) {

            ForEach(SettingsSection.allCases) { section in
                TokenBarSettingsNavItem(
                    section: section,
                    isSelected: selectedSection == section
                ) {
                    selectedSection = section
                }
            }

            Spacer(minLength: 0)
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
        case .appearance:
            MenuBarSettingsView(store: store)
        case .alerts:
            alertsSection
        case .advanced:
            AdvancedProvidersView(
                store: store,
                expandedProviderIDs: $expandedAdvancedProviderIDs
            )
        }
    }

    private var providersSection: some View {
        VStack(alignment: .leading, spacing: TokenBarMetrics.spacing + 4) {
            TokenBarPanelTitle(
                title: "Providers",
                subtitle: "Connect the services you want TokenBar to track."
            )

            if store.accounts.count > 1 {
                TokenBarGlassCard {
                    VStack(alignment: .leading, spacing: TokenBarMetrics.innerSpacing) {
                        TokenBarSectionHeader(title: "Primary provider")
                        TokenBarSectionSubtitle(text: "Which connected provider drives the menu bar label.")
                        Picker("Primary provider", selection: activeAccountBinding) {
                            ForEach(store.accounts) { account in
                                Text(account.displayName).tag(Optional(account.id))
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.menu)
                    }
                }
            }

            VStack(alignment: .leading, spacing: TokenBarMetrics.innerSpacing) {
                TokenBarSectionHeader(title: "Active connections")
                if store.accounts.isEmpty {
                    TokenBarGlassCard {
                        TokenBarSectionSubtitle(
                            text: "No providers yet. Expand an option below to connect Cursor, OpenAI, Anthropic, or another source."
                        )
                    }
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
                TokenBarSectionHeader(title: "Add a provider")
                if addableProviders.isEmpty {
                    TokenBarGlassCard {
                        TokenBarSectionSubtitle(
                            text: store.accounts.isEmpty
                                ? "No provider types registered."
                                : "All available providers are connected."
                        )
                    }
                } else {
                    ForEach(addableProviders) { provider in
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

    private var addableProviders: [ProviderDescriptor] {
        let connectedProviderIDs = Set(store.accounts.map(\.providerID))
        return store.availableProviders.filter { !connectedProviderIDs.contains($0.id) }
    }

    private var alertsSection: some View {
        VStack(alignment: .leading, spacing: TokenBarMetrics.spacing + 4) {
            TokenBarPanelTitle(
                title: "Alerts",
                subtitle: "Usage notifications and automatic refresh."
            )

            TokenBarGlassCard {
                VStack(alignment: .leading, spacing: TokenBarMetrics.innerSpacing) {
                    Toggle("Usage alerts", isOn: Binding(
                        get: { store.notificationsEnabled },
                        set: { store.notificationsEnabled = $0 }
                    ))

                    TokenBarSectionSubtitle(
                        text: "Alerts fire at 50%, 75%, 90%, and 100% usage, or when exhaustion is forecast within 7 days. Each threshold notifies once per billing cycle."
                    )
                }
            }

            TokenBarGlassCard {
                VStack(alignment: .leading, spacing: TokenBarMetrics.innerSpacing) {
                    TokenBarSectionHeader(title: "Automatic refresh")
                    Picker("Refresh interval", selection: Binding(
                        get: { store.refreshInterval },
                        set: { store.refreshInterval = $0 }
                    )) {
                        ForEach(RefreshInterval.allCases) { interval in
                            Text(interval.label).tag(interval)
                        }
                    }
                    .pickerStyle(.radioGroup)

                    if let lastRefresh = store.lastRefreshAt {
                        TokenBarSectionSubtitle(
                            text: "Last updated \(lastRefresh.formatted(date: .abbreviated, time: .shortened))."
                        )
                    }
                    if let nextRefresh = store.nextRefreshAt {
                        TokenBarSectionSubtitle(
                            text: "Next refresh \(nextRefresh.formatted(date: .abbreviated, time: .shortened))."
                        )
                    }

                    Button(store.isRefreshing ? "Refreshing…" : "Refresh now") {
                        Task { await store.refresh() }
                    }
                    .buttonStyle(.glassProminent)
                    .disabled(store.isRefreshing)
                }
            }

            if store.alerts.isEmpty {
                TokenBarGlassCard {
                    Text("No alerts yet.")
                        .foregroundStyle(.secondary)
                }
            } else {
                TokenBarSectionHeader(title: "Recent")
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

    private var activeAccountBinding: Binding<UUID?> {
        Binding(
            get: { store.activeAccountID },
            set: { newValue in
                guard let newValue else { return }
                store.selectAccount(newValue)
            }
        )
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
