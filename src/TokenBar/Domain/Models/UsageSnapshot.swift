import Foundation

struct UsageSnapshot: Equatable, Sendable {
    let accountID: UUID
    let providerID: String
    let providerName: String
    let usagePercent: Double?
    let creditsRemaining: Double?
    let spendAmount: Decimal?
    let spendCurrency: String?
    let quotaUsed: Double?
    let quotaLimit: Double?
    let capturedAt: Date

    var usageFraction: Double? {
        guard let usagePercent else { return nil }
        return usagePercent / 100
    }

    var normalizedUsagePercent: Double? {
        if let usagePercent {
            return usagePercent
        }
        guard let quotaUsed, let quotaLimit, quotaLimit > 0 else {
            return nil
        }
        return (quotaUsed / quotaLimit) * 100
    }
}
