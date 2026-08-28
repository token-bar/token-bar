import Foundation
@testable import TokenBar

final class InMemoryCredentialStore: ProviderCredentialStore, @unchecked Sendable {
    private var storage: [CredentialKey: String] = [:]
    private let lock = NSLock()

    func save(_ value: String, for key: CredentialKey) throws {
        lock.lock()
        defer { lock.unlock() }
        storage[key] = value
    }

    func load(for key: CredentialKey) throws -> String? {
        lock.lock()
        defer { lock.unlock() }
        return storage[key]
    }

    func delete(for key: CredentialKey) throws {
        lock.lock()
        defer { lock.unlock() }
        storage.removeValue(forKey: key)
    }
}
