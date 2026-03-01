//
//  KeychainTokenStore.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import Foundation
import Security

public actor KeychainTokenStore: TokenStore {
    private let service: String
    private let account: String
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(service: String, account: String = "auth.tokens") {
        self.service = service
        self.account = account
    }

    public func readTokens() async -> AuthTokens? {
        do {
            guard let data = try readData() else { return nil }
            return try decoder.decode(AuthTokens.self, from: data)
        } catch {
            try? deleteItem()
            return nil
        }
    }

    public func saveTokens(_ tokens: AuthTokens) async {
        do {
            let data = try encoder.encode(tokens)
            try upsert(data: data)
        } catch {
            
        }
    }

    public func clearTokens() async {
        try? deleteItem()
    }
}

private extension KeychainTokenStore {

    func baseQuery() -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }

    func readData() throws -> Data? {
        var query = baseQuery()
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        switch status {
        case errSecSuccess:
            return item as? Data
        case errSecItemNotFound:
            return nil
        default:
            throw KeychainError.unhandledStatus(status)
        }
    }

    func upsert(data: Data) throws {
        let attributesToUpdate: [String: Any] = [kSecValueData as String: data]
        let updateStatus = SecItemUpdate(baseQuery() as CFDictionary, attributesToUpdate as CFDictionary)

        switch updateStatus {
        case errSecSuccess:
            return
        case errSecItemNotFound:
            var addQuery = baseQuery()
            addQuery[kSecValueData as String] = data
            addQuery[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly

            let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
            guard addStatus == errSecSuccess else {
                throw KeychainError.unhandledStatus(addStatus)
            }
        default:
            throw KeychainError.unhandledStatus(updateStatus)
        }
    }

    func deleteItem() throws {
        let status = SecItemDelete(baseQuery() as CFDictionary)
        switch status {
        case errSecSuccess, errSecItemNotFound:
            return
        default:
            throw KeychainError.unhandledStatus(status)
        }
    }
}

public enum KeychainError: Error, Sendable {
    case unhandledStatus(OSStatus)
}
