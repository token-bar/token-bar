import Foundation

struct ProviderAccount: Identifiable, Equatable, Sendable {
    let id: UUID
    let providerID: String
    let displayName: String
    var isConnected: Bool
    var connectionStatus: ProviderConnectionStatus

    init(
        id: UUID = UUID(),
        providerID: String,
        displayName: String,
        isConnected: Bool = false,
        connectionStatus: ProviderConnectionStatus = .disconnected
    ) {
        self.id = id
        self.providerID = providerID
        self.displayName = displayName
        self.isConnected = isConnected
        self.connectionStatus = connectionStatus
    }
}
