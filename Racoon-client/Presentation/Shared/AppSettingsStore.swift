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
    @Published private(set) var settings: AppSettings = AppSettings()

    private let storage: AppSettingsStorage
    private let syncTheme: SyncThemeFromProfileUseCase
    private let syncHiddenAccounts: SyncHiddenAccountsUseCase
    private let eventBus: DomainEventBus

    init(
        storage: AppSettingsStorage,
        syncTheme: SyncThemeFromProfileUseCase,
        syncHiddenAccounts: SyncHiddenAccountsUseCase,
        eventBus: DomainEventBus
    ) {
        self.storage = storage
        self.syncTheme = syncTheme
        self.syncHiddenAccounts = syncHiddenAccounts
        self.eventBus = eventBus
        
        self.settings = storage.load()
        
        listenForEvents()
    }

    private func listenForEvents() {
        Task {
            for await event in eventBus.events {
             
                if case .themeSwitched = event {
                    self.settings = storage.load()
                } else if case .visibilityChanged = event {
                    self.settings = storage.load()
                }
            }
        }
    }

    func bootstrapLocal() {
        self.settings = storage.load()
    }

    func syncFromBackend() async {
        _ = try? await syncTheme()

        _ = try? await syncHiddenAccounts()
        
        self.settings = storage.load()
    }
}
