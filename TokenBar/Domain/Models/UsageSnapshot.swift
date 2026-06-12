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
}
