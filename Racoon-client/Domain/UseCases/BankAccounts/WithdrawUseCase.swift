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
    public init(repo: CoreBankAccountRepository, events: DomainEventBus) {
        self.repo = repo
        self.events = events
    }

    public func callAsFunction(accountId: UUID, amount: Decimal) async throws -> BankAccount {
        let dto = try await repo.withdraw(id: accountId, amount: (amount as NSDecimalNumber).doubleValue)
        await events.publish(.moneyWithdrawn(accountId: accountId, amount: amount))
        return BankAccountMapper.toDomain(dto)
    }
}
