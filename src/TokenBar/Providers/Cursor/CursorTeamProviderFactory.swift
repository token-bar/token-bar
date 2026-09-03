import Foundation

struct CursorTeamProviderFactory: ProviderFactory {
    var descriptor: ProviderDescriptor {
        ProviderDescriptor(
            id: CursorTeamProviderConnector.providerID,
            displayName: "Cursor Team",
            authenticationMethod: .apiKey,
            stability: .stable,
            connectsOnLaunch: false
        )
    }

    func makeConnector(context: ProviderFactoryContext) -> any ProviderConnector {
        let credentialKey = CredentialKey(
            providerID: CursorTeamProviderConnector.providerID,
            kind: .apiKey
        )
        let apiKey = (try? context.credentials.load(for: credentialKey)) ?? ""
        let configuration = context.configuration.load(
            providerID: CursorTeamProviderConnector.providerID
        )

        return DemoModeConnectorFactory.make(
            providerID: CursorTeamProviderConnector.providerID,
            displayName: descriptor.displayName,
            demoTrigger: apiKey
        ) {
            let client = CursorTeamAPIClient(
                apiKey: apiKey,
                urlSession: context.urlSession
            )

            return CursorTeamProviderConnector(
                apiClient: client,
                memberEmail: configuration.memberEmail
            )
        }
    }
}
