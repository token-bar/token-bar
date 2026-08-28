import Foundation

struct ProviderFactoryContext: Sendable {
    let credentials: any ProviderCredentialStore
    let configuration: ProviderConfigurationStore
    let demoScenarioState: DemoScenarioStateStore
    let urlSession: URLSession

    static func makeDefault(
        credentials: any ProviderCredentialStore = KeychainCredentialStore(),
        configurationStore: ProviderConfigurationStore = ProviderConfigurationStore(),
        demoScenarioStateStore: DemoScenarioStateStore = DemoScenarioStateStore()
    ) -> ProviderFactoryContext {
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.timeoutIntervalForRequest = 5
        sessionConfiguration.timeoutIntervalForResource = 5
        let session = URLSession(configuration: sessionConfiguration)

        return ProviderFactoryContext(
            credentials: credentials,
            configuration: configurationStore,
            demoScenarioState: demoScenarioStateStore,
            urlSession: session
        )
    }
}
