//
//  WithdrawUseCase.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import Foundation

public protocol WithdrawUseCase: Sendable {
    func callAsFunction(accountId: UUID, amount: Decimal) async throws -> BankAccount
}

public struct WithdrawUseCaseImpl: WithdrawUseCase {
    private let repo: CoreBankAccountRepository
    private let events: DomainEventBus
    private let hiddenStorage: AppSettingsStorage
    
    public init(
        repo: CoreBankAccountRepository,
        events: DomainEventBus,
        hiddenStorage: AppSettingsStorage
    ) {
        self.repo = repo
        self.events = events
        self.hiddenStorage = hiddenStorage
    }

    public func callAsFunction(accountId: UUID, amount: Decimal) async throws -> BankAccount {
        let dto = try await repo.withdraw(id: accountId, amount: (amount as NSDecimalNumber).doubleValue)
        
        await events.publish(.moneyWithdrawn(accountId: accountId, amount: amount))
        
        let hiddenIds = hiddenStorage.load().hiddenAccountIds
        return BankAccountMapper.toDomain(dto, hiddenAccountIds: hiddenIds)
    }
}
