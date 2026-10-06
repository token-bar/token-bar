import Foundation
import Security

struct KeychainCredentialStore: ProviderCredentialStore {
    private static let probeKey = CredentialKey(providerID: "__keychain_probe__", kind: .apiKey)

    private let service: String

    init(service: String = "icu.charlie.TokenBar.credentials") {
        self.service = service
    }

    /// Triggers macOS keychain access at launch so users see Allow/Deny before saving a provider.
    func prepareAccessIfNeeded() {
        try? save("probe", for: Self.probeKey)
        try? delete(for: Self.probeKey)
    }

    func save(_ value: String, for key: CredentialKey) throws {
        let account = accountName(for: key)
        guard let data = value.data(using: .utf8) else {
            throw CredentialStoreError.encodingFailed
        }

        let query = baseQuery(account: account)
        let attributes = valueAttributes(data: data)

        let status = SecItemCopyMatching(query as CFDictionary, nil)
        switch status {
        case errSecSuccess:
            let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
            if updateStatus == errSecSuccess {
                return
            }
            if isAccessDenied(updateStatus) {
                deleteSilently(query: query)
                try addItem(query: query, attributes: attributes)
                return
            }
            throw CredentialStoreError.keychainError(updateStatus)
        case errSecItemNotFound:
            try addItem(query: query, attributes: attributes)
        default:
            if isAccessDenied(status) {
                deleteSilently(query: query)
                try addItem(query: query, attributes: attributes)
                return
            }
            throw CredentialStoreError.keychainError(status)
        }
    }

    func load(for key: CredentialKey) throws -> String? {
        let account = accountName(for: key)
        var query = baseQuery(account: account)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        switch status {
        case errSecItemNotFound:
            return nil
        case errSecSuccess:
            guard let data = item as? Data, let value = String(data: data, encoding: .utf8) else {
                throw CredentialStoreError.encodingFailed
            }
            return value
        default:
            if isAccessDenied(status) {
                deleteSilently(query: baseQuery(account: account))
                return nil
            }
            throw CredentialStoreError.keychainError(status)
        }
    }

    func delete(for key: CredentialKey) throws {
        let query = baseQuery(account: accountName(for: key))
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw CredentialStoreError.keychainError(status)
        }
    }

    private func baseQuery(account: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
    }

    private func valueAttributes(data: Data) -> [String: Any] {
        [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
        ]
    }

    private func addItem(query: [String: Any], attributes: [String: Any]) throws {
        var addQuery = query
        addQuery.merge(attributes) { _, new in new }
        let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
        guard addStatus == errSecSuccess else {
            throw CredentialStoreError.keychainError(addStatus)
        }
    }

    private func deleteSilently(query: [String: Any]) {
        _ = SecItemDelete(query as CFDictionary)
    }

    private func isAccessDenied(_ status: OSStatus) -> Bool {
        status == errSecAuthFailed || status == errSecInteractionNotAllowed
    }

    private func accountName(for key: CredentialKey) -> String {
        "\(key.providerID).\(key.kind.rawValue)"
    }
}
