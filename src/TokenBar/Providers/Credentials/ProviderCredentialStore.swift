import Foundation

protocol ProviderCredentialStore: Sendable {
    func save(_ value: String, for key: CredentialKey) throws
    func load(for key: CredentialKey) throws -> String?
    func delete(for key: CredentialKey) throws
}

enum CredentialStoreError: Error, Equatable {
    case encodingFailed
    case notFound
    case keychainError(OSStatus)
}
