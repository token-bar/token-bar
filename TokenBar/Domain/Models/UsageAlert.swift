import Foundation

struct UsageAlert: Identifiable, Equatable, Sendable {
    let id: UUID
    let accountID: UUID
    let thresholdPercent: Int
    let triggeredAt: Date

    init(
        id: UUID = UUID(),
        accountID: UUID,
        thresholdPercent: Int,
        triggeredAt: Date = .now
    ) {
        self.id = id
        self.accountID = accountID
        self.thresholdPercent = thresholdPercent
        self.triggeredAt = triggeredAt
    }
}
