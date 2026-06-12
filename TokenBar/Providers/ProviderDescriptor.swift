import Foundation

enum ProviderAuthenticationMethod: String, Equatable, Sendable {
    case none
    case apiKey
    case oauth
    case sessionToken
    case proxy
}

struct ProviderDescriptor: Equatable, Sendable, Identifiable {
    let id: String
    let displayName: String
    let authenticationMethod: ProviderAuthenticationMethod
    let connectsOnLaunch: Bool

    init(
        id: String,
        displayName: String,
        authenticationMethod: ProviderAuthenticationMethod,
        connectsOnLaunch: Bool = false
    ) {
        self.id = id
        self.displayName = displayName
        self.authenticationMethod = authenticationMethod
        self.connectsOnLaunch = connectsOnLaunch
    }
}
