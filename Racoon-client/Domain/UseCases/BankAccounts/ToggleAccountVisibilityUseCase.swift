//
//  ToggleAccountVisibilityUseCase.swift
//  Racoon-client
//
//  Created by dark type on 30.03.2026.
//

import Foundation

public protocol ToggleAccountVisibilityUseCase: Sendable {
    func callAsFunction(id: UUID, isCurrentlyHidden: Bool) async throws
}

public struct ToggleAccountVisibilityUseCaseImpl: ToggleAccountVisibilityUseCase {
    private let appRepo: AppRepository
    private let storage: HiddenAccountsStorage
    private let events: DomainEventBus
    
    public init(appRepo: AppRepository, storage: HiddenAccountsStorage, events: DomainEventBus) {
        self.appRepo = appRepo
        self.storage = storage
        self.events = events
    }
    
    public func callAsFunction(id: UUID, isCurrentlyHidden: Bool) async throws {
        if isCurrentlyHidden {
            try await appRepo.revealBankAccount(id: id)
            storage.removeHiddenAccount(id: id)
        } else {
            try await appRepo.hideBankAccount(id: id)
            storage.addHiddenAccount(id: id)
        }
        
        await events.publish(.visibilityChanged(accountId: id))
    }
}
