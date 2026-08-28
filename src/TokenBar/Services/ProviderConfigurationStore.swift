import Foundation

struct ProviderConfiguration: Codable, Equatable, Sendable {
    var memberEmail: String?
    var proxyURL: String?
    var connectionMethod: CursorPersonalConnectionMethod?
    var monthlyBudgetUSD: Double?
    var demoUsagePercent: Double?
    var demoSpendUSD: Double?
    var demoCreditsRemaining: Double?
    var demoUsageIncrementPerRefresh: Double?

    static let empty = ProviderConfiguration()
}

struct ProviderConfigurationStore: @unchecked Sendable {
    private let defaults: UserDefaults
    private let keyPrefix = "provider.config."

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load(providerID: String) -> ProviderConfiguration {
        guard let data = defaults.data(forKey: storageKey(providerID)),
              let configuration = try? JSONDecoder().decode(ProviderConfiguration.self, from: data) else {
            return .empty
        }
        return configuration
    }

    func save(_ configuration: ProviderConfiguration, providerID: String) {
        guard let data = try? JSONEncoder().encode(configuration) else {
            return
        }
        defaults.set(data, forKey: storageKey(providerID))
    }

    func delete(providerID: String) {
        defaults.removeObject(forKey: storageKey(providerID))
    }

    private func storageKey(_ providerID: String) -> String {
        keyPrefix + providerID
    }
}
