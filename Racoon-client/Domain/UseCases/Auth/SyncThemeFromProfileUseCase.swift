//
//  SyncThemeFromProfileUseCase.swift
//  Racoon-client
//
//  Created by dark type on 23.03.2026.
//


public protocol SyncThemeFromProfileUseCase: Sendable {
    func callAsFunction() async throws -> AppSettings
}
public struct SyncThemeFromProfileUseCaseImpl: SyncThemeFromProfileUseCase {
    private let getProfile: GetProfileUseCase
    private let storage: AppSettingsStorage
    private let events: DomainEventBus

    public init(
        getProfile: GetProfileUseCase,
        storage: AppSettingsStorage,
        events: DomainEventBus
    ) {
        self.getProfile = getProfile
        self.storage = storage
        self.events = events
    }

    public func callAsFunction() async throws -> AppSettings {
        let profile = try await getProfile()
        let current = storage.load()
        let newTheme = AppThemePreference(profileTheme: profile.theme)

        let updated = AppSettings(
            theme: newTheme,
            hiddenAccountIds: current.hiddenAccountIds
        )

        storage.save(updated)
        await events.publish(.themeSwitched)
       

        return updated
    }
}
