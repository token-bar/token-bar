import Foundation

struct ProviderAccount: Identifiable, Equatable, Sendable {
    let id: UUID
    let providerID: String
    let displayName: String
    var isConnected: Bool

    init(
        id: UUID = UUID(),
        providerID: String,
        displayName: String,
        isConnected: Bool = false
    ) {
        self.id = id
        self.providerID = providerID
        self.displayName = displayName
        self.isConnected = isConnected
    }
}
