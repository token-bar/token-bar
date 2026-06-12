import SwiftUI

@available(macOS 14.0, *)
struct MenuBarView: View {
    let store: UsageStore
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            providerSection
            Divider()
            usageSection
            forecastSection
            refreshSection
            Divider()
            Button("Open Settings…") {
                openSettings()
            }
        }
        .padding()
        .frame(width: 280)
    }

    @ViewBuilder
    private var providerSection: some View {
        if store.accounts.isEmpty {
            Text("No providers configured")
                .foregroundStyle(.secondary)
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
    private var usageSection: some View {
        if let snapshot = store.activeSnapshot {
            VStack(alignment: .leading, spacing: 4) {
                Text(snapshot.providerName)
                    .font(.headline)
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
        } else if store.isRefreshing {
            Text("Refreshing…")
                .foregroundStyle(.secondary)
        } else if let error = store.lastError {
            Text(error)
                .foregroundStyle(.red)
        } else {
            Text("No usage data")
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var forecastSection: some View {
        if let forecast = store.activeForecast {
            VStack(alignment: .leading, spacing: 4) {
                Text("Forecast")
                    .font(.subheadline.weight(.semibold))
                if let burnRate = forecast.burnRatePerDay {
                    Text("Burn rate: \(burnRate.formatted(.number.precision(.fractionLength(1))))%/day")
                        .foregroundStyle(.secondary)
                }
                if let exhaustion = forecast.estimatedExhaustionDate {
                    Text("Est. exhaustion: \(exhaustion.formatted(date: .abbreviated, time: .omitted))")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var refreshSection: some View {
        HStack {
            if let lastRefresh = store.lastRefreshAt {
                Text("Updated \(lastRefresh.formatted(date: .omitted, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button("Refresh") {
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
}
