import Foundation

enum MenuBarDisplayFormatter {
    private static let progressSegments = 10

    static func format(
        snapshot: UsageSnapshot?,
        forecast: UsageForecast? = nil,
        aggregate: AggregatedUsageSummary? = nil,
        snapshots: [UsageSnapshot] = [],
        mode: DisplayMode
    ) -> String {
        if mode == .aggregate, snapshots.count > 1 {
            return formatAggregate(snapshots: snapshots)
        }

        guard let snapshot else { return "TokenBar" }

        switch mode {
        case .percentage:
            let percent = snapshot.usagePercent.map { Int($0.rounded()) } ?? 0
            return "\(snapshot.providerName) \(percent)%"
        case .spend:
            guard let amount = snapshot.spendAmount else {
                return snapshot.providerName
            }
            let formatted = Self.currencyFormatter.string(from: amount as NSDecimalNumber) ?? "\(amount)"
            return "\(snapshot.providerName) \(formatted)"
        case .credits:
            guard let credits = snapshot.creditsRemaining else {
                return snapshot.providerName
            }
            return "\(snapshot.providerName) \(Int(credits)) cr"
        case .progressBar:
            return progressBar(for: snapshot.usagePercent)
        case .burnRate:
            guard let burnRate = forecast?.burnRatePerDay else {
                return snapshot.providerName
            }
            let formatted = burnRate.formatted(
                .number.precision(.fractionLength(1)).locale(Self.fixedNumberLocale)
            )
            return "\(snapshot.providerName) \(formatted)%/d"
        case .aggregate:
            let percent = snapshot.usagePercent.map { Int($0.rounded()) } ?? 0
            return "\(snapshot.providerName) \(percent)%"
        }
    }

    static func formatMetric(
        snapshot: UsageSnapshot,
        forecast: UsageForecast? = nil,
        mode: DisplayMode
    ) -> String {
        switch mode {
        case .percentage, .aggregate:
            let percent = snapshot.usagePercent.map { Int($0.rounded()) } ?? 0
            return "\(percent)%"
        case .spend:
            guard let amount = snapshot.spendAmount else {
                return snapshot.providerName
            }
            return Self.currencyFormatter.string(from: amount as NSDecimalNumber) ?? "\(amount)"
        case .credits:
            guard let credits = snapshot.creditsRemaining else {
                return snapshot.providerName
            }
            return "\(Int(credits)) cr"
        case .progressBar:
            return progressBar(for: snapshot.usagePercent)
        case .burnRate:
            guard let burnRate = forecast?.burnRatePerDay else {
                return snapshot.providerName
            }
            let formatted = burnRate.formatted(
                .number.precision(.fractionLength(1)).locale(Self.fixedNumberLocale)
            )
            return "\(formatted)%/d"
        }
    }

    static func formatAggregate(snapshots: [UsageSnapshot]) -> String {
        snapshots
            .sorted { $0.providerName.localizedCaseInsensitiveCompare($1.providerName) == .orderedAscending }
            .map { snapshot in
                let percent = snapshot.usagePercent.map { Int($0.rounded()) } ?? 0
                return "\(snapshot.providerName) \(percent)%"
            }
            .joined(separator: " · ")
    }

    static func progressBar(for usagePercent: Double?) -> String {
        let filled = usagePercent.map { Int(($0 / 100 * Double(progressSegments)).rounded()) } ?? 0
        let clamped = min(max(filled, 0), progressSegments)
        let empty = progressSegments - clamped
        return String(repeating: "▰", count: clamped) + String(repeating: "▱", count: empty)
    }

    private static let fixedNumberLocale = Locale(identifier: "en_US_POSIX")

    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter
    }()
}
