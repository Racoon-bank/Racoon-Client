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
    private let loadRemote: LoadAppSettingsUseCase

    init(
        storage: AppSettingsStorage,
        loadRemote: LoadAppSettingsUseCase
    ) {
        self.storage = storage
        self.loadRemote = loadRemote
        self.settings = storage.load()
    }

    func bootstrap() async {
        let local = storage.load()
        settings = local

        do {
            let remote = try await loadRemote()
            settings = remote
            storage.save(remote)
        } catch {
          
        }
    }

    func setTheme(_ theme: AppThemePreference) {
        let updated = settings.withTheme(theme)
        settings = updated
        storage.save(updated)
    }

    func toggleHidden(accountId: UUID) {
        let updated = settings.togglingHidden(accountId: accountId.uuidString)
        settings = updated
        storage.save(updated)
    }

    func isHidden(accountId: UUID) -> Bool {
        settings.hiddenAccountIds.contains(accountId.uuidString)
    }
}
