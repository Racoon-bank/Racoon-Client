//
//  RepayCreditUseCase.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import Foundation

public protocol RepayCreditUseCase: Sendable {
    func callAsFunction(creditId: Int64, bankAccountId: UUID, amount: Decimal) async throws -> CreditPayment
}

public struct RepayCreditUseCaseImpl: RepayCreditUseCase {
    private let creditRepo: CreditRepository
    private let events: DomainEventBus

    public init(creditRepo: CreditRepository, events: DomainEventBus) {
        self.creditRepo = creditRepo
        self.events = events
    }

    public func callAsFunction(creditId: Int64, bankAccountId: UUID, amount: Decimal) async throws -> CreditPayment {
        let dto = try await creditRepo.repay(
            creditId: creditId,
            bankAccountId: bankAccountId.uuidString,
            amount: NSDecimalNumber(decimal: amount).doubleValue
        )
        await events.publish(.creditRepaid(creditId: creditId, amount: amount))
        return CreditMapper.toDomain(dto)
    }
}
