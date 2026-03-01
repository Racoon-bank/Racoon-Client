//
//  GetCreditScheduleUseCase.swift
//  Racoon-client
//
//  Created by dark type on 01.03.2026.
//


public protocol GetCreditScheduleUseCase: Sendable {
    func callAsFunction(creditId: Int64) async throws -> [PaymentScheduleItem]
}

public struct GetCreditScheduleUseCaseImpl: GetCreditScheduleUseCase {
    private let creditRepo: CreditRepository
    public init(creditRepo: CreditRepository) { self.creditRepo = creditRepo }

    public func callAsFunction(creditId: Int64) async throws -> [PaymentScheduleItem] {
        let dtos = try await creditRepo.schedule(creditId: creditId)
        return dtos.map(PaymentScheduleMapper.toDomain)
    }
}