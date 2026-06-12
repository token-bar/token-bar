import Foundation

struct MockProviderFactory: ProviderFactory {
    static let providerID = "mock"

    var descriptor: ProviderDescriptor {
        ProviderDescriptor(
            id: Self.providerID,
            displayName: "Demo Provider",
            authenticationMethod: .none,
            stability: .stable,
            connectsOnLaunch: true,
            experimentalNotice: "Simulated usage for testing alerts, forecasts, and display modes without real provider accounts."
        )
    }

    func makeConnector(context: ProviderFactoryContext) -> any ProviderConnector {
        return MockProviderConnector(
            configurationStore: context.configuration,
            scenarioStateStore: context.demoScenarioState
        )
    }
}
