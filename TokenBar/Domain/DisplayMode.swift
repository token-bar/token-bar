import Foundation

enum DisplayMode: String, CaseIterable, Identifiable, Sendable {
    case percentage
    case progressBar
    case spend
    case credits
    case burnRate

    var id: String { rawValue }

    var label: String {
        switch self {
        case .percentage: "Percentage"
        case .progressBar: "Progress Bar"
        case .spend: "Spend"
        case .credits: "Credits"
        case .burnRate: "Burn Rate"
        }
    }
}
