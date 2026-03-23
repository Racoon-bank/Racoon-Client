//
//  SyncHiddenAccountsUseCase.swift
//  Racoon-client
//
//  Created by dark type on 23.03.2026.
//

import Foundation

public protocol SyncHiddenAccountsUseCase: Sendable {
    func callAsFunction() async throws -> AppSettings
}
public struct SyncHiddenAccountsUseCaseImpl: SyncHiddenAccountsUseCase {
    private let getAccounts: GetMyAccountsUseCase
    private let storage: AppSettingsStorage

    public init(
        getAccounts: GetMyAccountsUseCase,
        storage: AppSettingsStorage
    ) {
        self.getAccounts = getAccounts
        self.storage = storage
    }

    public func callAsFunction() async throws -> AppSettings {
        let accounts = try await getAccounts()
        let hiddenIds = Set(
            accounts
                .filter { $0.isHidden }
                .map { $0.id.uuidString }
        )

        let current = storage.load()
        let updated = AppSettings(
            theme: current.theme,
            hiddenAccountIds: hiddenIds
        )

        storage.save(updated)
        return updated
    }
}
