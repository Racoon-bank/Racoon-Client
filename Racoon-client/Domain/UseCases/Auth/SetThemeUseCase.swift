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
    private let storage: AppSettingsStorage
    private let events: DomainEventBus

    public init(storage: AppSettingsStorage, events: DomainEventBus) {
        self.storage = storage
        self.events = events
    }

    public func callAsFunction(_ theme: AppThemePreference) async throws {
        let updated = storage.load().withTheme(theme)
        storage.save(updated)

        let domainTheme: Theme
        switch theme {
        case .light: domainTheme = .Light
        case .dark: domainTheme = .Dark
        case .system:
            return
        }

        await events.publish(.themeSwitched)
    }
}
