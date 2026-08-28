import Foundation

enum ForecastRiskLevel: String, Equatable, Sendable {
    case low
    case medium
    case high
    case critical
}

struct UsageForecast: Equatable, Sendable {
    let accountID: UUID
    let burnRatePerDay: Double?
    let daysRemaining: Double?
    let estimatedExhaustionDate: Date?
    let confidenceScore: Double?
    let riskLevel: ForecastRiskLevel
}
