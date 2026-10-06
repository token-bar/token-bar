import Foundation

enum ProviderAuthenticationMethod: String, Equatable, Sendable, CaseIterable {
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
    let stability: ProviderStability
    let connectsOnLaunch: Bool
    let isAdvanced: Bool
    let experimentalNotice: String?

    init(
        id: String,
        displayName: String,
        authenticationMethod: ProviderAuthenticationMethod,
        stability: ProviderStability,
        connectsOnLaunch: Bool = false,
        isAdvanced: Bool = false,
        experimentalNotice: String? = nil
    ) {
        self.id = id
        self.displayName = displayName
        self.authenticationMethod = authenticationMethod
        self.stability = stability
        self.connectsOnLaunch = connectsOnLaunch
        self.isAdvanced = isAdvanced
        self.experimentalNotice = experimentalNotice
    }
}
