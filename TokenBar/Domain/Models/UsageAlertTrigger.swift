import Foundation

enum UsageAlertTrigger: String, Codable, Equatable, Hashable, Sendable, CaseIterable {
    case threshold50 = "threshold.50"
    case threshold75 = "threshold.75"
    case threshold90 = "threshold.90"
    case threshold100 = "threshold.100"
    case forecastExhaustion = "forecast.exhaustion"

    static let usageThresholdPercents = [50, 75, 90, 100]

    var thresholdPercent: Int? {
        switch self {
        case .threshold50: 50
        case .threshold75: 75
        case .threshold90: 90
        case .threshold100: 100
        case .forecastExhaustion: nil
        }
    }

    var isForecastExhaustion: Bool {
        self == .forecastExhaustion
    }

    static func forThreshold(_ percent: Int) -> UsageAlertTrigger? {
        switch percent {
        case 50: .threshold50
        case 75: .threshold75
        case 90: .threshold90
        case 100: .threshold100
        default: nil
        }
    }
}
