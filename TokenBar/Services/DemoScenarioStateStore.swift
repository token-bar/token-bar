import Foundation

struct DemoScenarioState: Codable, Equatable, Sendable {
    var currentUsagePercent: Double
}

struct DemoScenarioStateStore: @unchecked Sendable {
    private let defaults: UserDefaults
    private let keyPrefix = "demo.scenario."

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load(providerID: String) -> DemoScenarioState? {
        guard let data = defaults.data(forKey: storageKey(providerID)),
              let state = try? JSONDecoder().decode(DemoScenarioState.self, from: data) else {
            return nil
        }
        return state
    }

    func save(_ state: DemoScenarioState, providerID: String) {
        guard let data = try? JSONEncoder().encode(state) else {
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
