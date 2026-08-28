import Foundation

struct UsageHistorySample: Codable, Equatable, Sendable {
    let accountID: UUID
    let capturedAt: Date
    let usagePercent: Double?
    let quotaUsed: Double?
    let quotaLimit: Double?

    init(
        accountID: UUID,
        capturedAt: Date,
        usagePercent: Double?,
        quotaUsed: Double? = nil,
        quotaLimit: Double? = nil
    ) {
        self.accountID = accountID
        self.capturedAt = capturedAt
        self.usagePercent = usagePercent
        self.quotaUsed = quotaUsed
        self.quotaLimit = quotaLimit
    }

    init(snapshot: UsageSnapshot) {
        self.init(
            accountID: snapshot.accountID,
            capturedAt: snapshot.capturedAt,
            usagePercent: snapshot.usagePercent,
            quotaUsed: snapshot.quotaUsed,
            quotaLimit: snapshot.quotaLimit
        )
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
