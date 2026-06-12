import Foundation

enum MenuBarDisplayFormatter {
    private static let progressSegments = 10

    static func format(
        snapshot: UsageSnapshot?,
        forecast: UsageForecast? = nil,
        mode: DisplayMode
    ) -> String {
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
            let formatted = burnRate.formatted(.number.precision(.fractionLength(1)))
            return "\(snapshot.providerName) \(formatted)%/d"
        }
    }

    static func progressBar(for usagePercent: Double?) -> String {
        let filled = usagePercent.map { Int(($0 / 100 * Double(progressSegments)).rounded()) } ?? 0
        let clamped = min(max(filled, 0), progressSegments)
        let empty = progressSegments - clamped
        return String(repeating: "▰", count: clamped) + String(repeating: "▱", count: empty)
    }

    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter
    }()
}

