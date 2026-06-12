import Foundation

enum AlertEvaluator {
    static let forecastExhaustionWithinDays = 7.0

    struct Input: Equatable, Sendable {
        let accountID: UUID
        let previousUsagePercent: Double?
        let currentUsagePercent: Double?
        let previousDaysRemaining: Double?
        let currentDaysRemaining: Double?
        let triggered: Set<UsageAlertTrigger>
    }

    struct Output: Equatable, Sendable {
        let newAlerts: [UsageAlert]
        let updatedTriggered: Set<UsageAlertTrigger>
    }

    static func evaluate(input: Input, now: Date = .now) -> Output {
        var triggered = input.triggered

        if quotaResetDetected(
            previous: input.previousUsagePercent,
            current: input.currentUsagePercent
        ) {
            triggered = []
        }

        var newAlerts: [UsageAlert] = []

        for threshold in UsageAlertTrigger.usageThresholdPercents {
            guard let trigger = UsageAlertTrigger.forThreshold(threshold),
                  !triggered.contains(trigger),
                  crossedThreshold(
                      previous: input.previousUsagePercent,
                      current: input.currentUsagePercent,
                      threshold: threshold
                  ) else {
                continue
            }

            newAlerts.append(
                UsageAlert(
                    accountID: input.accountID,
                    trigger: trigger,
                    triggeredAt: now
                )
            )
            triggered.insert(trigger)
        }

        let forecastTrigger = UsageAlertTrigger.forecastExhaustion
        if !triggered.contains(forecastTrigger),
           crossedForecastExhaustion(
               previous: input.previousDaysRemaining,
               current: input.currentDaysRemaining
           ) {
            newAlerts.append(
                UsageAlert(
                    accountID: input.accountID,
                    trigger: forecastTrigger,
                    triggeredAt: now
                )
            )
            triggered.insert(forecastTrigger)
        }

        return Output(newAlerts: newAlerts, updatedTriggered: triggered)
    }

    static func quotaResetDetected(previous: Double?, current: Double?) -> Bool {
        guard let previous, let current else {
            return false
        }
        return previous - current >= ForecastingEngine.resetDropThreshold
    }

    static func crossedThreshold(previous: Double?, current: Double?, threshold: Int) -> Bool {
        guard let current, current >= Double(threshold) else {
            return false
        }
        return (previous ?? 0) < Double(threshold)
    }

    static func crossedForecastExhaustion(previous: Double?, current: Double?) -> Bool {
        guard let current, current <= forecastExhaustionWithinDays else {
            return false
        }
        return (previous ?? .infinity) > forecastExhaustionWithinDays
    }
}
