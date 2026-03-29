//
//  ToggleHiddenAccountUseCase.swift
//  Racoon-client
//
//  Created by dark type on 22.03.2026.
//

import Foundation

public protocol ToggleHiddenAccountUseCase: Sendable {
    func callAsFunction(accountId: UUID) async throws
}
public struct ToggleHiddenAccountUseCaseImpl: ToggleHiddenAccountUseCase {
    private let storage: AppSettingsStorage
    private let events: DomainEventBus

    public init(storage: AppSettingsStorage, events: DomainEventBus) {
        self.storage = storage
        self.events = events
    }

    public func callAsFunction(accountId: UUID) async throws {
        let updated = storage.load().togglingHidden(accountId: accountId)
        storage.save(updated)
        await events.publish(.visibilityChanged(accountId: accountId))
    }
}
