//
//  TakeCreditUseCase.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import Foundation

public protocol TakeCreditUseCase: Sendable {
    func callAsFunction(bankAccountId: UUID, tariffId: Int64, amount: Decimal, durationMonths: Int) async throws -> TakeCreditResult
}

public struct TakeCreditUseCaseImpl: TakeCreditUseCase {
    private let repo: CreditRepository
    
    public init(repo: CreditRepository) {
        self.repo = repo
    }

    public func callAsFunction(bankAccountId: UUID, tariffId: Int64, amount: Decimal, durationMonths: Int) async throws -> TakeCreditResult {
        let dto = try await repo.take(
            bankAccountId: bankAccountId.uuidString.lowercased(),
            tariffId: tariffId,
            amount: (amount as NSDecimalNumber).doubleValue,
            durationMonths: durationMonths
        )
        return CreditMapper.toDomain(dto)
    }
}
