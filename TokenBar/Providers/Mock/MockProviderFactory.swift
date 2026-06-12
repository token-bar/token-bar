import Foundation

struct MockProviderFactory: ProviderFactory {
    static let providerID = "mock"

    var descriptor: ProviderDescriptor {
        ProviderDescriptor(
            id: Self.providerID,
            displayName: "Cursor (Mock)",
            authenticationMethod: .none,
            connectsOnLaunch: true
        )
    }

    func makeConnector() -> any ProviderConnector {
        MockProviderConnector()
    }
}
