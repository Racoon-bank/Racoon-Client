//
//  DepositUseCase.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import Foundation

public protocol DepositUseCase: Sendable {
    func callAsFunction(accountId: UUID, amount: Decimal) async throws -> BankAccount
}

public struct DepositUseCaseImpl: DepositUseCase {
    private let repo: CoreBankAccountRepository
    private let events: DomainEventBus
    private let hiddenStorage: AppSettingsStorage

    public init(
        repo: CoreBankAccountRepository,
        events: DomainEventBus = NoopDomainEventBus(),
        hiddenStorage: AppSettingsStorage
    ) {
        self.repo = repo
        self.events = events
        self.hiddenStorage = hiddenStorage
    }

    public func callAsFunction(accountId: UUID, amount: Decimal) async throws -> BankAccount {
        let dto = try await repo.deposit(id: accountId, amount: (amount as NSDecimalNumber).doubleValue)
        let hiddenIds = hiddenStorage.load().hiddenAccountIds
        
        let domain = BankAccountMapper.toDomain(dto, hiddenAccountIds: hiddenIds)
        
        await events.publish(.moneyDeposited(accountId: accountId, amount: amount))
        return domain
    }
}
