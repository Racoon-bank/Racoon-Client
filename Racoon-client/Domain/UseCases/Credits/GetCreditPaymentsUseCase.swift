//
//  GetCreditPaymentsUseCase.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import Foundation

public protocol GetCreditPaymentsUseCase: Sendable {
    func callAsFunction(creditId: Int64) async throws -> [CreditPayment]
}

public struct GetCreditPaymentsUseCaseImpl: GetCreditPaymentsUseCase {
    private let creditRepo: CreditRepository

    public init(creditRepo: CreditRepository) { self.creditRepo = creditRepo }

    public func callAsFunction(creditId: Int64) async throws -> [CreditPayment] {
        let dtos = try await creditRepo.payments(creditId: creditId)
        return dtos.map(CreditMapper.toDomain)
    }
}
