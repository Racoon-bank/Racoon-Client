//
//  AppSettingsStore.swift
//  Racoon-client
//
//  Created by dark type on 18.03.2026.
//

import Combine
import Foundation

@MainActor
final class AppSettingsStore: ObservableObject {
    @Published private(set) var settings: AppSettings = .init()

    private let storage: AppSettingsStorage
    private let syncTheme: SyncThemeFromProfileUseCase
    private let syncHiddenAccounts: SyncHiddenAccountsUseCase

    init(
        storage: AppSettingsStorage,
        syncTheme: SyncThemeFromProfileUseCase,
        syncHiddenAccounts: SyncHiddenAccountsUseCase
    ) {
        self.storage = storage
        self.syncTheme = syncTheme
        self.syncHiddenAccounts = syncHiddenAccounts
        self.settings = storage.load()
    }

    func bootstrapLocal() {
        settings = storage.load()
    }

    func syncFromBackend() async {
        do {
            _ = try await syncTheme()
            settings = storage.load()
        } catch {
            
        }

        do {
            _ = try await syncHiddenAccounts()
            settings = storage.load()
        } catch {
            
        }
    }

    func setThemeLocally(_ theme: AppThemePreference) {
        let updated = settings.withTheme(theme)
        settings = updated
        storage.save(updated)
    }

    func setHiddenLocally(accountId: UUID, hidden: Bool) {
        var ids = settings.hiddenAccountIds
        if hidden {
            ids.insert(accountId.uuidString)
        } else {
            ids.remove(accountId.uuidString)
        }

        let updated = settings.withHiddenAccountIds(ids)
        settings = updated
        storage.save(updated)
    }

    func toggleHiddenLocally(accountId: UUID) {
        let updated = settings.togglingHidden(accountId: accountId.uuidString)
        settings = updated
        storage.save(updated)
    }

    func isHidden(accountId: UUID) -> Bool {
        settings.hiddenAccountIds.contains(accountId.uuidString)
    }
}
