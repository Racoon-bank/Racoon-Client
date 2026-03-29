//
//  SetThemeUseCase.swift
//  Racoon-client
//
//  Created by dark type on 22.03.2026.
//


public protocol SetThemeUseCase: Sendable {
    func callAsFunction(_ theme: AppThemePreference) async throws
}

public struct SetThemeUseCaseImpl: SetThemeUseCase {
    private let appRepo: AppRepository
    private let storage: AppSettingsStorage
    private let events: DomainEventBus

    public init(appRepo: AppRepository, storage: AppSettingsStorage, events: DomainEventBus) {
        self.appRepo = appRepo
        self.storage = storage
        self.events = events
    }

    public func callAsFunction(_ theme: AppThemePreference) async throws {
        let current = storage.load()
        
        if current.theme != theme {
            _ = try? await appRepo.switchTheme()
        }

        let updated = current.withTheme(theme)
        storage.save(updated)

        await events.publish(.themeSwitched)
    }
}
