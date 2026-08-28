import Foundation

struct UsageAlert: Identifiable, Equatable, Sendable {
    let id: UUID
    let accountID: UUID
    let trigger: UsageAlertTrigger
    let triggeredAt: Date

    init(
        id: UUID = UUID(),
        accountID: UUID,
        trigger: UsageAlertTrigger,
        triggeredAt: Date = .now
    ) {
        self.id = id
        self.accountID = accountID
        self.trigger = trigger
        self.triggeredAt = triggeredAt
    }

    var summary: String {
        if let thresholdPercent = trigger.thresholdPercent {
            return "\(thresholdPercent)% usage reached"
        }
        return "Quota exhaustion forecast within 7 days"
    }
}
