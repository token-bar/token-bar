import Foundation

enum MenuBarDisplayFormatter {
    private static let progressSegments = 10

    static func format(
        snapshot: UsageSnapshot?,
        forecast: UsageForecast? = nil,
        aggregate: AggregatedUsageSummary? = nil,
        mode: DisplayMode
    ) -> String {
        if mode == .aggregate, let aggregate, aggregate.providerCount > 1 {
            return formatAggregate(aggregate)
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

    static func formatAggregate(_ aggregate: AggregatedUsageSummary) -> String {
        if let percent = aggregate.highestUsagePercent {
            return "TokenBar \(Int(percent.rounded()))% max"
        }
        if let spend = aggregate.totalSpendUSD {
            let formatted = Self.currencyFormatter.string(from: spend as NSDecimalNumber) ?? "\(spend)"
            return "TokenBar \(formatted)"
        }
        return "TokenBar \(aggregate.providerCount) providers"
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
