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
    let estimatedExhaustionDate: Date?
    let riskLevel: ForecastRiskLevel
}
