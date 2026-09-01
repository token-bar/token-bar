import SwiftUI

struct GeneralSettingsView: View {
    let store: UsageStore

    private var overview: DashboardOverview {
        DashboardOverviewBuilder.build(
            snapshots: store.snapshots,
            forecasts: store.forecasts,
            accounts: store.accounts,
            activeAccountID: store.activeAccountID,
            lastRefreshAt: store.lastRefreshAt,
            isRefreshing: store.isRefreshing
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: TokenBarMetrics.spacing + 4) {
            TokenBarPanelTitle(
                title: "Overview",
                subtitle: "Usage insights across your connected AI providers."
            )

            if overview.hasConnectedProviders {
                heroCard
                if overview.chartItems.count > 1 {
                    comparisonCard
                }
                providersSection
                if let forecast = overview.activeForecast {
                    forecastCard(forecast)
                }
                refreshCard
            } else {
                emptyStateCard
            }
        }
    }

    private var heroCard: some View {
        TokenBarGlassCard {
            VStack(alignment: .leading, spacing: TokenBarMetrics.spacing) {
                HStack(alignment: .top, spacing: TokenBarMetrics.spacing + 4) {
                    if let percent = overview.activeUsagePercent ?? overview.summary.highestUsagePercent {
                        TokenBarUsageRing(percent: percent)
                    } else {
                        placeholderRing
                    }

                    VStack(alignment: .leading, spacing: TokenBarMetrics.innerSpacing + 2) {
                        if let name = overview.activeProviderName ?? overview.summary.highestUsageProviderName {
                            Text(name)
                                .font(.title3.weight(.semibold))
                        }
                        Text(heroSubtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)

                        if let risk = overview.summary.highestRiskLevel {
                            Label(risk.rawValue.capitalized, systemImage: "exclamationmark.triangle.fill")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(TokenBarRiskColor.color(for: risk))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                    spacing: TokenBarMetrics.innerSpacing
                ) {
                    TokenBarMetricPill(
                        title: "Providers",
                        value: "\(overview.summary.providerCount)"
                    )
                    if let spend = overview.summary.totalSpendUSD {
                        TokenBarMetricPill(
                            title: "Total spend",
                            value: spend.formatted(.currency(code: "USD"))
                        )
                    }
                    if let percent = overview.summary.highestUsagePercent,
                       let provider = overview.summary.highestUsageProviderName {
                        TokenBarMetricPill(
                            title: "Peak usage",
                            value: "\(Int(percent.rounded()))% · \(provider)",
                            tint: TokenBarUsageColor.color(forPercent: percent)
                        )
                    }
                    if let credits = overview.summary.lowestCreditsRemaining,
                       let provider = overview.summary.lowestCreditsProviderName {
                        TokenBarMetricPill(
                            title: "Lowest credits",
                            value: "\(Int(credits)) · \(provider)"
                        )
                    }
                }
            }
        }
    }

    private var comparisonCard: some View {
        TokenBarGlassCard {
            VStack(alignment: .leading, spacing: TokenBarMetrics.innerSpacing + 2) {
                TokenBarSectionHeader(title: "Usage comparison")
                TokenBarSectionSubtitle(text: "Relative usage across connected providers.")
                TokenBarProviderUsageChart(items: overview.chartItems)
            }
        }
    }

    private var providersSection: some View {
        VStack(alignment: .leading, spacing: TokenBarMetrics.innerSpacing) {
            TokenBarSectionHeader(title: "Providers")
            ForEach(overview.providers) { provider in
                providerCard(provider)
            }
        }
    }

    private func providerCard(_ provider: DashboardProviderInsight) -> some View {
        TokenBarGlassCard {
            VStack(alignment: .leading, spacing: TokenBarMetrics.innerSpacing + 2) {
                HStack(spacing: TokenBarMetrics.innerSpacing) {
                    ProviderBrandIcon(providerID: provider.providerID, size: 16)
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text(provider.providerName)
                                .font(.subheadline.weight(.semibold))
                            if provider.isActive {
                                Text("Menu bar")
                                    .font(.caption2.weight(.semibold))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(.quaternary.opacity(0.55), in: Capsule())
                            }
                        }
                        Text(provider.connectionStatus.label)
                            .font(.caption)
                            .foregroundStyle(connectionColor(for: provider.connectionStatus))
                    }
                    Spacer(minLength: 0)
                    if let percent = provider.usagePercent {
                        Text("\(Int(percent.rounded()))%")
                            .font(.title3.weight(.bold))
                            .monospacedDigit()
                            .foregroundStyle(TokenBarUsageColor.color(forPercent: percent))
                    }
                }

                if let fraction = provider.usageFraction {
                    TokenBarUsageProgressTrack(
                        fraction: fraction,
                        percent: provider.usagePercent
                    )
                }

                HStack(spacing: TokenBarMetrics.innerSpacing) {
                    if let spend = provider.spendAmount {
                        metricDetail(
                            title: "Spend",
                            value: spend.formatted(.currency(code: provider.spendCurrency ?? "USD"))
                        )
                    }
                    if let credits = provider.creditsRemaining {
                        metricDetail(title: "Credits", value: "\(Int(credits))")
                    }
                    if let burnRate = provider.forecast?.burnRatePerDay {
                        metricDetail(
                            title: "Burn rate",
                            value: "\(burnRate.formatted(.number.precision(.fractionLength(1))))%/day"
                        )
                    }
                    if let days = provider.forecast?.daysRemaining {
                        metricDetail(
                            title: "Days left",
                            value: days.formatted(.number.precision(.fractionLength(0...1)))
                        )
                    }
                }
            }
        }
    }

    private func forecastCard(_ forecast: UsageForecast) -> some View {
        TokenBarGlassCard {
            VStack(alignment: .leading, spacing: TokenBarMetrics.innerSpacing + 2) {
                HStack {
                    TokenBarSectionHeader(title: "Forecast")
                    Spacer(minLength: 0)
                    Text(forecast.riskLevel.rawValue.capitalized)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(TokenBarRiskColor.color(for: forecast.riskLevel))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            TokenBarRiskColor.color(for: forecast.riskLevel).opacity(0.15),
                            in: Capsule()
                        )
                }

                if let exhaustion = forecast.estimatedExhaustionDate {
                    TokenBarSectionSubtitle(
                        text: "Estimated limit around \(exhaustion.formatted(date: .abbreviated, time: .omitted))."
                    )
                }
                if let confidence = forecast.confidenceScore {
                    TokenBarUsageProgressTrack(
                        fraction: confidence,
                        percent: confidence * 100,
                        height: 6
                    )
                    Text("Confidence \(Int((confidence * 100).rounded()))%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var refreshCard: some View {
        TokenBarGlassCard {
            HStack(spacing: TokenBarMetrics.innerSpacing) {
                VStack(alignment: .leading, spacing: 4) {
                    if let lastRefresh = overview.lastRefreshAt {
                        Text("Updated \(lastRefresh.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Usage has not refreshed yet.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer(minLength: 0)
                Button(store.isRefreshing ? "Refreshing…" : "Refresh now") {
                    Task { await store.refresh() }
                }
                .buttonStyle(.glassProminent)
                .disabled(store.isRefreshing)
            }
        }
    }

    private var emptyStateCard: some View {
        TokenBarGlassCard {
            VStack(alignment: .leading, spacing: TokenBarMetrics.innerSpacing + 4) {
                Label("No providers connected", systemImage: "point.3.connected.trianglepath.dotted")
                    .font(.headline)
                TokenBarSectionSubtitle(
                    text: "Connect Cursor, OpenAI, Anthropic, or another source in Providers to see usage rings, progress bars, and forecasts here."
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
        }
    }

    private var placeholderRing: some View {
        ZStack {
            Circle()
                .stroke(.quaternary.opacity(0.8), lineWidth: 9)
            Image(systemName: "chart.pie")
                .font(.title2)
                .foregroundStyle(.secondary)
        }
        .frame(width: 88, height: 88)
    }

    private var heroSubtitle: String {
        if overview.activeProviderName != nil {
            return "Active menu bar provider · \(overview.summary.providerCount) connected"
        }
        return "\(overview.summary.providerCount) providers connected"
    }

    private func metricDetail(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption.weight(.medium))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func connectionColor(for status: ProviderConnectionStatus) -> Color {
        switch status {
        case .connected: .secondary
        case .disconnected, .unavailable: .secondary
        default: .orange
        }
    }
}
