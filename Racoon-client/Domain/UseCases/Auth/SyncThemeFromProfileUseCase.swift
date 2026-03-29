//
//  SyncThemeFromProfileUseCase.swift
//  Racoon-client
//
//  Created by dark type on 23.03.2026.
//

import Foundation

public protocol SyncThemeFromProfileUseCase: Sendable {
    func callAsFunction() async throws -> AppSettings
}

public struct SyncThemeFromProfileUseCaseImpl: SyncThemeFromProfileUseCase {
    private let appRepo: AppRepository
    private let storage: AppSettingsStorage
    private let events: DomainEventBus

    public init(
        appRepo: AppRepository,
        storage: AppSettingsStorage,
        events: DomainEventBus
    ) {
        self.appRepo = appRepo
        self.storage = storage
        self.events = events
    }

    public func callAsFunction() async throws -> AppSettings {
        
        let appInfo = try await appRepo.getAppInfo()
        
        let mappedTheme: AppThemePreference
        if appInfo.theme == "Dark" {
            mappedTheme = .dark
        } else {
            mappedTheme = .light
        }
        
        let hiddenIds = Set(appInfo.hiddenBankAccounts ?? [])

        let updated = AppSettings(
            theme: mappedTheme,
            hiddenAccountIds: hiddenIds
        )

        storage.save(updated)
        
        await events.publish(.themeSwitched)

        return updated
    }
}
