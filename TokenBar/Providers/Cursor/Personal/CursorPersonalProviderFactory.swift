import Foundation

struct CursorPersonalProviderFactory: ProviderFactory {
    private static let experimentalNotice =
        "This integration relies on undocumented Cursor dashboard APIs and may stop working if Cursor changes its internal implementation."

    var descriptor: ProviderDescriptor {
        ProviderDescriptor(
            id: CursorPersonalProviderConnector.providerID,
            displayName: "Cursor Personal",
            authenticationMethod: .sessionToken,
            stability: .experimental,
            experimentalNotice: Self.experimentalNotice
        )
    }

    func makeConnector(context: ProviderFactoryContext) -> any ProviderConnector {
        let configuration = context.configuration.load(
            providerID: CursorPersonalProviderConnector.providerID
        )
        let method = configuration.connectionMethod ?? .sessionCookie

        switch method {
        case .sessionCookie:
            let tokenKey = CredentialKey(
                providerID: CursorPersonalProviderConnector.providerID,
                kind: .sessionCookie
            )
            let token = (try? context.credentials.load(for: tokenKey)) ?? ""
            let dashboard = ExperimentalCursorPersonalDashboardClient(urlSession: context.urlSession)
            return CursorPersonalProviderConnector(
                dashboard: dashboard,
                sessionToken: token
            )
        case .customProxy:
            let endpoint = configuration.proxyURL.flatMap(URL.init(string:))
                ?? URL(string: "https://invalid.local")!
            let tokenKey = CredentialKey(
                providerID: CursorPersonalProviderConnector.providerID,
                kind: .proxyToken
            )
            let token = try? context.credentials.load(for: tokenKey)
            return ProxyProviderConnector(
                endpoint: endpoint,
                proxyToken: token,
                urlSession: context.urlSession,
                providerID: CursorPersonalProviderConnector.providerID,
                displayName: "Cursor Personal"
            )
        }
    }
}
