//
//  CloseAccountUseCase.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import Foundation

public protocol CloseAccountUseCase: Sendable {
    func callAsFunction(accountId: UUID) async throws
}

public struct CloseAccountUseCaseImpl: CloseAccountUseCase {
    private let repo: CoreBankAccountRepository
    private let events: DomainEventBus

    public init(repo: CoreBankAccountRepository, events: DomainEventBus = NoopDomainEventBus()) {
        self.repo = repo
        self.events = events
    }

    public func callAsFunction(accountId: UUID) async throws {
        try await repo.closeAccount(id: accountId)
        await events.publish(.bankAccountClosed(accountId: accountId))
    }
}
