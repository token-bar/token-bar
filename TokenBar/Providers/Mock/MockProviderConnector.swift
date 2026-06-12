import Foundation

struct MockProviderConnector: ProviderConnector {
    let providerID = "mock"
    let displayName = "Cursor"
    let accountID: UUID

    private let configurationStore: ProviderConfigurationStore
    private let scenarioStateStore: DemoScenarioStateStore

    init(
        accountID: UUID = UUID(),
        configurationStore: ProviderConfigurationStore = ProviderConfigurationStore(),
        scenarioStateStore: DemoScenarioStateStore = DemoScenarioStateStore()
    ) {
        self.accountID = accountID
        self.configurationStore = configurationStore
        self.scenarioStateStore = scenarioStateStore
    }

    func authenticate() async throws {}

    func disconnect() async {}

    func validateConnection() async throws -> Bool {
        true
    }

    func fetchUsage() async throws -> UsageSnapshot {
        let configuration = configurationStore.load(providerID: providerID)
        let existingState = scenarioStateStore.load(providerID: providerID)
        let (usagePercent, nextState) = DemoScenarioEngine.resolveUsagePercent(
            configuration: configuration,
            state: existingState,
            incrementPerRefresh: configuration.demoUsageIncrementPerRefresh
        )
        scenarioStateStore.save(nextState, providerID: providerID)

        return DemoScenarioEngine.makeSnapshot(
            accountID: accountID,
            providerID: providerID,
            displayName: displayName,
            configuration: configuration,
            usagePercent: usagePercent
        )
    }
}
