import SwiftUI

struct MenuBarView: View {
    let store: UsageStore
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        TokenBarGlassPanel(style: .menuBar) {
            VStack(alignment: .leading, spacing: TokenBarMetrics.spacing) {
                providerSection
                aggregateSection
                TokenBarPanelDivider()
                usageSection
                allProvidersSection
                forecastSection
                if !store.accounts.isEmpty {
                    refreshSection
                    TokenBarPanelDivider()
                }
                TokenBarPanelButton(title: "Settings…") {
                    TokenBarAppActivation.prepareForSettingsPresentation()
                    openWindow(id: "settings")
                }
            }
        }
    }

    @ViewBuilder
    private var providerSection: some View {
        if store.accounts.isEmpty {
            TokenBarGlassCard {
                VStack(alignment: .leading, spacing: 4) {
                    Text("No providers connected")
                        .font(.subheadline.weight(.medium))
                    Text("Open Settings to add Cursor, OpenAI, Anthropic, or a demo source.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        } else {
            Picker("Provider", selection: activeAccountBinding) {
                ForEach(store.accounts) { account in
                    Text(account.displayName).tag(Optional(account.id))
                }
            }
            .pickerStyle(.menu)
        }
    }

    @ViewBuilder
    private var aggregateSection: some View {
        let summary = store.aggregatedSummary
        if summary.providerCount > 1 {
            TokenBarGlassCard {
                VStack(alignment: .leading, spacing: 4) {
                    TokenBarSectionHeader(title: "All providers")
                    Text("\(summary.providerCount) connected")
                        .foregroundStyle(.secondary)
                    if let percent = summary.highestUsagePercent,
                       let provider = summary.highestUsageProviderName {
                        Text("Peak: \(Int(percent.rounded()))% · \(provider)")
                            .foregroundStyle(.secondary)
                    }
                    if let spend = summary.totalSpendUSD {
                        Text("Spend: \(spend.formatted(.currency(code: "USD")))")
                            .foregroundStyle(.secondary)
                    }
                    if let risk = summary.highestRiskLevel {
                        Text("Risk: \(risk.rawValue.capitalized)")
                            .font(.caption)
                            .foregroundStyle(TokenBarRiskColor.color(for: risk))
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var allProvidersSection: some View {
        if store.snapshots.count > 1 {
            TokenBarGlassCard {
                VStack(alignment: .leading, spacing: 6) {
                    TokenBarSectionHeader(title: "By provider")
                    ForEach(store.snapshots, id: \.accountID) { snapshot in
                        HStack {
                            Text(snapshot.providerName)
                            Spacer()
                            if let percent = snapshot.usagePercent {
                                Text("\(Int(percent.rounded()))%")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .font(.caption)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var usageSection: some View {
        if let snapshot = store.activeSnapshot {
            TokenBarGlassCard {
                VStack(alignment: .leading, spacing: 4) {
                    TokenBarSectionHeader(title: snapshot.providerName)
                    if let percent = snapshot.usagePercent {
                        Text("\(Int(percent.rounded()))% used")
                    }
                    if let spend = snapshot.spendAmount {
                        Text("Spend: \(spend.formatted(.currency(code: snapshot.spendCurrency ?? "USD")))")
                            .foregroundStyle(.secondary)
                    }
                    if let credits = snapshot.creditsRemaining {
                        Text("Credits: \(Int(credits))")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        } else if let error = store.lastError {
            Text(error)
                .foregroundStyle(.red)
        } else if !store.accounts.isEmpty {
            Text("No usage data yet")
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var forecastSection: some View {
        if let forecast = store.activeForecast {
            TokenBarGlassCard {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        TokenBarSectionHeader(title: "Forecast")
                        Spacer()
                        Text(forecast.riskLevel.rawValue.capitalized)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(TokenBarRiskColor.color(for: forecast.riskLevel))
                    }
                    if let burnRate = forecast.burnRatePerDay {
                        Text("Burn: \(burnRate.formatted(.number.precision(.fractionLength(1))))%/day")
                            .foregroundStyle(.secondary)
                    }
                    if let daysRemaining = forecast.daysRemaining {
                        Text("Days left: \(daysRemaining.formatted(.number.precision(.fractionLength(0...1))))")
                            .foregroundStyle(.secondary)
                    }
                    if let exhaustion = forecast.estimatedExhaustionDate {
                        Text("Est. limit: \(exhaustion.formatted(date: .abbreviated, time: .omitted))")
                            .foregroundStyle(.secondary)
                    }
                    if let confidence = forecast.confidenceScore {
                        Text("Confidence: \(Int((confidence * 100).rounded()))%")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private var refreshSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let lastRefresh = store.lastRefreshAt {
                Text("Updated \(lastRefresh.formatted(date: .omitted, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            TokenBarPanelButton(
                title: store.isRefreshing ? "Refreshing…" : "Refresh now",
                isDisabled: store.isRefreshing
            ) {
                Task { await store.refresh() }
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
}
