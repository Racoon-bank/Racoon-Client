//
//  ChangeVisibilityUseCase.swift
//  Racoon-client
//
//  Created by dark type on 18.03.2026.
//

import Foundation

public protocol ChangeVisibilityUseCase: Sendable {
    func callAsFunction(accountId: UUID) async throws
}

public struct ChangeVisibilityUseCaseImpl: ChangeVisibilityUseCase {
    private let repo: CoreBankAccountRepository
    private let events: DomainEventBus

    public init(repo: CoreBankAccountRepository, events: DomainEventBus = NoopDomainEventBus()) {
        self.repo = repo
        self.events = events
    }

    public func callAsFunction(accountId: UUID) async throws {
        try await repo.changeVisibility(id: accountId)
        await events.publish(.visibilityChanged(accountId: accountId))
    }
}
