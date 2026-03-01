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

    public init(repo: CoreBankAccountRepository, events: DomainEventBus = NoopDomainEventBus()) {
        self.repo = repo
        self.events = events
    }

    public func callAsFunction(accountId: UUID, amount: Decimal) async throws -> BankAccount {
        let dto = try await repo.deposit(id: accountId, amount: (amount as NSDecimalNumber).doubleValue)
        let domain = BankAccountMapper.toDomain(dto)
        await events.publish(.moneyDeposited(accountId: accountId, amount: amount))
        return domain
    }
}
