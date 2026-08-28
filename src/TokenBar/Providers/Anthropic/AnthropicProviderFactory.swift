import Foundation

struct AnthropicProviderFactory: ProviderFactory {
    var descriptor: ProviderDescriptor {
        ProviderDescriptor(
            id: AnthropicProviderConnector.providerID,
            displayName: "Anthropic",
            authenticationMethod: .apiKey,
            stability: .stable,
            connectsOnLaunch: false
        )
    }

    func makeConnector(context: ProviderFactoryContext) -> any ProviderConnector {
        let credentialKey = CredentialKey(
            providerID: AnthropicProviderConnector.providerID,
            kind: .apiKey
        )
        let apiKey = (try? context.credentials.load(for: credentialKey)) ?? ""
        let configuration = context.configuration.load(
            providerID: AnthropicProviderConnector.providerID
        )

        let client = AnthropicAdminAPIClient(
            adminAPIKey: apiKey,
            urlSession: context.urlSession
        )

        return AnthropicProviderConnector(
            apiClient: client,
            monthlyBudgetUSD: configuration.monthlyBudgetUSD
        )
    }
}
