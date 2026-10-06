import Foundation

struct MenuBarProviderUsageItem: Identifiable, Equatable, Sendable {
    let id: UUID
    let providerID: String
    let providerName: String
    let usagePercent: Double?

    init(
        id: UUID = UUID(),
        providerID: String,
        providerName: String,
        usagePercent: Double?
    ) {
        self.id = id
        self.providerID = providerID
        self.providerName = providerName
        self.usagePercent = usagePercent
    }

    var percentLabel: String {
        guard let usagePercent else { return "—" }
        return "\(Int(usagePercent.rounded()))%"
    }

    var compactLabel: String {
        "\(providerName) \(percentLabel)"
    }
}

enum MenuBarAggregateItems {
    static func from(snapshots: [UsageSnapshot]) -> [MenuBarProviderUsageItem] {
        snapshots
            .sorted { $0.providerName.localizedCaseInsensitiveCompare($1.providerName) == .orderedAscending }
            .map {
                MenuBarProviderUsageItem(
                    id: $0.accountID,
                    providerID: $0.providerID,
                    providerName: $0.providerName,
                    usagePercent: $0.usagePercent
                )
            }
    }
}
