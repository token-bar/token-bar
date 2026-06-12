import Foundation

struct CredentialKey: Hashable, Sendable {
    let providerID: String
    let kind: Kind

    enum Kind: String, Sendable {
        case apiKey
        case sessionCookie
        case proxyToken
    }
}
