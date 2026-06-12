import Foundation

struct MockProviderFactory: ProviderFactory {
    static let providerID = "mock"

    var descriptor: ProviderDescriptor {
        ProviderDescriptor(
            id: Self.providerID,
            displayName: "Cursor (Mock)",
            authenticationMethod: .none,
            stability: .stable,
            connectsOnLaunch: true
        )
    }

    func makeConnector(context: ProviderFactoryContext) -> any ProviderConnector {
        MockProviderConnector()
    }
}
