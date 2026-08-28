import Foundation

struct OpenAIProviderFactory: ProviderFactory {
    var descriptor: ProviderDescriptor {
        ProviderDescriptor(
            id: OpenAIProviderConnector.providerID,
            displayName: "OpenAI",
            authenticationMethod: .apiKey,
            stability: .stable,
            connectsOnLaunch: false
        )
    }

    func makeConnector(context: ProviderFactoryContext) -> any ProviderConnector {
        let credentialKey = CredentialKey(
            providerID: OpenAIProviderConnector.providerID,
            kind: .apiKey
        )
        let apiKey = (try? context.credentials.load(for: credentialKey)) ?? ""
        let configuration = context.configuration.load(
            providerID: OpenAIProviderConnector.providerID
        )

        let client = OpenAIAdminAPIClient(
            adminAPIKey: apiKey,
            urlSession: context.urlSession
        )

        return OpenAIProviderConnector(
            apiClient: client,
            monthlyBudgetUSD: configuration.monthlyBudgetUSD
        )
    }
}
