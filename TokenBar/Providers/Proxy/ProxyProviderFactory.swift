import Foundation

struct ProxyProviderFactory: ProviderFactory {
    var descriptor: ProviderDescriptor {
        ProviderDescriptor(
            id: ProxyProviderConnector.advancedProviderID,
            displayName: "Custom Proxy",
            authenticationMethod: .proxy,
            stability: .experimental,
            isAdvanced: true,
            experimentalNotice: "Power-user integration using a custom HTTPS endpoint."
        )
    }

    func makeConnector(context: ProviderFactoryContext) -> any ProviderConnector {
        let configuration = context.configuration.load(
            providerID: ProxyProviderConnector.advancedProviderID
        )
        let endpoint = configuration.proxyURL.flatMap(URL.init(string:))
            ?? URL(string: "https://invalid.local")!
        let tokenKey = CredentialKey(
            providerID: ProxyProviderConnector.advancedProviderID,
            kind: .proxyToken
        )
        let token = try? context.credentials.load(for: tokenKey)

        return ProxyProviderConnector(
            endpoint: endpoint,
            proxyToken: token,
            urlSession: context.urlSession,
            providerID: ProxyProviderConnector.advancedProviderID,
            displayName: "Custom Proxy"
        )
    }
}
