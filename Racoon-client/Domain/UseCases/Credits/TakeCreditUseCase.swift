//
//  TakeCreditUseCase.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import Foundation

public protocol TakeCreditUseCase: Sendable {
    func callAsFunction(bankAccountId: UUID, tariffId: Int64, amount: Decimal, durationMonths: Int) async throws -> Credit
}

public struct TakeCreditUseCaseImpl: TakeCreditUseCase {
    private let creditRepo: CreditRepository
    private let events: DomainEventBus

    public init(creditRepo: CreditRepository, events: DomainEventBus) {
        self.creditRepo = creditRepo
        self.events = events
    }

    public func callAsFunction(bankAccountId: UUID, tariffId: Int64, amount: Decimal, durationMonths: Int) async throws -> Credit {
        let dto = try await creditRepo.take(
            bankAccountId: bankAccountId.uuidString,
            tariffId: tariffId,
            amount: NSDecimalNumber(decimal: amount).doubleValue,
            durationMonths: durationMonths
        )
        await events.publish(.creditTaken(creditId: dto.id))
        return CreditMapper.toDomain(dto)
    }
}
