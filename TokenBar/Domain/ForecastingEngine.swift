import Foundation

enum ForecastingEngine {
    static let minimumElapsedDays = 1.0 / 24.0
    static let resetDropThreshold = 15.0

    static func forecast(
        accountID: UUID,
        current: UsageSnapshot,
        history: [UsageHistorySample],
        now: Date = .now
    ) -> UsageForecast {
        guard let currentUsage = current.normalizedUsagePercent else {
            return UsageForecast(
                accountID: accountID,
                burnRatePerDay: nil,
                daysRemaining: nil,
                estimatedExhaustionDate: nil,
                confidenceScore: nil,
                riskLevel: .low
            )
        }

        let accountHistory = history
            .filter { $0.accountID == accountID }
            .sorted { $0.capturedAt < $1.capturedAt }

        let segment = billingCycleSegment(
            history: accountHistory,
            current: UsageHistorySample(snapshot: current)
        )

        let burnRate = computeBurnRate(segment: segment)
        let daysRemaining = computeDaysRemaining(currentUsage: currentUsage, burnRatePerDay: burnRate)
        let exhaustionDate = daysRemaining.map { now.addingTimeInterval($0 * 86_400) }
        let confidence = computeConfidence(segment: segment, burnRate: burnRate)
        let risk = riskLevel(usagePercent: currentUsage, daysRemaining: daysRemaining)

        return UsageForecast(
            accountID: accountID,
            burnRatePerDay: burnRate,
            daysRemaining: daysRemaining,
            estimatedExhaustionDate: exhaustionDate,
            confidenceScore: confidence,
            riskLevel: risk
        )
    }

    static func billingCycleSegment(
        history: [UsageHistorySample],
        current: UsageHistorySample
    ) -> [UsageHistorySample] {
        var samples = history
        if samples.last?.capturedAt != current.capturedAt {
            samples.append(current)
        }

        var segmentStart = 0
        for index in 1..<samples.count {
            guard let previous = samples[index - 1].normalizedUsagePercent,
                  let next = samples[index].normalizedUsagePercent else {
                continue
            }
            if previous - next >= resetDropThreshold {
                segmentStart = index
            }
        }

        return Array(samples[segmentStart...])
    }

    static func computeBurnRate(segment: [UsageHistorySample]) -> Double? {
        guard segment.count >= 2,
              let firstUsage = segment.first?.normalizedUsagePercent,
              let lastUsage = segment.last?.normalizedUsagePercent else {
            return nil
        }

        let elapsedDays = segment.last!.capturedAt.timeIntervalSince(segment.first!.capturedAt) / 86_400
        guard elapsedDays >= minimumElapsedDays else {
            return nil
        }

        let delta = lastUsage - firstUsage
        guard delta > 0 else {
            return nil
        }

        return delta / elapsedDays
    }

    static func computeDaysRemaining(currentUsage: Double, burnRatePerDay: Double?) -> Double? {
        guard let burnRatePerDay, burnRatePerDay > 0 else {
            return nil
        }

        let remaining = 100 - currentUsage
        guard remaining > 0 else {
            return 0
        }

        return remaining / burnRatePerDay
    }

    static func computeConfidence(segment: [UsageHistorySample], burnRate: Double?) -> Double? {
        guard segment.count >= 2, let burnRate, burnRate > 0 else {
            return nil
        }

        let sampleScore = min(Double(segment.count), 10) / 10 * 0.4

        let elapsedDays = segment.last!.capturedAt.timeIntervalSince(segment.first!.capturedAt) / 86_400
        let spanScore = min(elapsedDays, 7) / 7 * 0.3

        let consistencyScore = intervalConsistencyScore(segment: segment, overallBurnRate: burnRate) * 0.3

        return min(sampleScore + spanScore + consistencyScore, 1.0)
    }

    static func intervalConsistencyScore(segment: [UsageHistorySample], overallBurnRate: Double) -> Double {
        guard segment.count >= 3 else {
            return 0.5
        }

        var intervalRates: [Double] = []
        for index in 1..<segment.count {
            guard let previous = segment[index - 1].normalizedUsagePercent,
                  let next = segment[index].normalizedUsagePercent else {
                continue
            }

            let elapsedDays = segment[index].capturedAt.timeIntervalSince(segment[index - 1].capturedAt) / 86_400
            guard elapsedDays >= minimumElapsedDays else {
                continue
            }

            let delta = next - previous
            guard delta > 0 else {
                continue
            }

            intervalRates.append(delta / elapsedDays)
        }

        guard !intervalRates.isEmpty else {
            return 0.5
        }

        let mean = intervalRates.reduce(0, +) / Double(intervalRates.count)
        let variance = intervalRates.reduce(0) { partial, rate in
            let diff = rate - mean
            return partial + diff * diff
        } / Double(intervalRates.count)

        let coefficientOfVariation = mean > 0 ? sqrt(variance) / mean : 1
        return max(0, 1 - min(coefficientOfVariation, 1))
    }

    static func riskLevel(usagePercent: Double, daysRemaining: Double?) -> ForecastRiskLevel {
        if usagePercent >= 90 {
            return .critical
        }
        if let daysRemaining {
            if daysRemaining <= 3 {
                return .critical
            }
            if daysRemaining <= 7 {
                return .high
            }
            if daysRemaining <= 14 {
                return .medium
            }
        }
        if usagePercent >= 75 {
            return .high
        }
        if usagePercent >= 50 {
            return .medium
        }
        return .low
    }
}
