import Foundation
import Security

struct KeychainCredentialStore: ProviderCredentialStore {
    private let service: String

    init(service: String = "com.tokenbar.TokenBar.credentials") {
        self.service = service
    }

    func save(_ value: String, for key: CredentialKey) throws {
        let account = accountName(for: key)
        guard let data = value.data(using: .utf8) else {
            throw CredentialStoreError.encodingFailed
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
        ]

        let status = SecItemCopyMatching(query as CFDictionary, nil)
        if status == errSecSuccess {
            let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
            guard updateStatus == errSecSuccess else {
                throw CredentialStoreError.keychainError(updateStatus)
            }
        } else if status == errSecItemNotFound {
            var addQuery = query
            addQuery.merge(attributes) { _, new in new }
            let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
            guard addStatus == errSecSuccess else {
                throw CredentialStoreError.keychainError(addStatus)
            }
        } else {
            throw CredentialStoreError.keychainError(status)
        }
    }

    func load(for key: CredentialKey) throws -> String? {
        let account = accountName(for: key)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecItemNotFound {
            return nil
        }
        guard status == errSecSuccess else {
            throw CredentialStoreError.keychainError(status)
        }
        guard let data = item as? Data, let value = String(data: data, encoding: .utf8) else {
            throw CredentialStoreError.encodingFailed
        }
        return value
    }

    func delete(for key: CredentialKey) throws {
        let account = accountName(for: key)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw CredentialStoreError.keychainError(status)
        }
    }

    private func accountName(for key: CredentialKey) -> String {
        "\(key.providerID).\(key.kind.rawValue)"
    }
}
