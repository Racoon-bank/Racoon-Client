//
//  TransferUseCase.swift
//  Racoon-client
//
//  Created by dark type on 18.03.2026.
//

import Foundation

public protocol TransferUseCase: Sendable {
    func callAsFunction(fromAccountId: UUID, toAccountNumber: String?, amount: Decimal) async throws -> BankAccount
}

public struct TransferUseCaseImpl: TransferUseCase {
    private let repo: CoreBankAccountRepository
    private let events: DomainEventBus

    public init(repo: CoreBankAccountRepository, events: DomainEventBus = NoopDomainEventBus()) {
        self.repo = repo
        self.events = events
    }

    public func callAsFunction(fromAccountId: UUID, toAccountNumber: String?, amount: Decimal) async throws -> BankAccount {
        let dto = try await repo.transfer(
            fromAccountId: fromAccountId, 
            toAccountNumber: toAccountNumber, 
            amount: (amount as NSDecimalNumber).doubleValue
        )
        let domain = BankAccountMapper.toDomain(dto)
        
        await events.publish(.moneyTransferred(
            fromAccountId: fromAccountId, 
            toAccountNumber: toAccountNumber, 
            amount: amount
        ))
        
        return domain
    }
}
