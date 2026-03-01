//
//  GetCreditStatisticsUseCase.swift
//  Racoon-client
//
//  Created by dark type on 01.03.2026.
//


public protocol GetCreditStatisticsUseCase: Sendable {
    func callAsFunction(creditId: Int64) async throws -> CreditStatistics
}

public struct GetCreditStatisticsUseCaseImpl: GetCreditStatisticsUseCase {
    private let creditRepo: CreditRepository
    public init(creditRepo: CreditRepository) { self.creditRepo = creditRepo }

    public func callAsFunction(creditId: Int64) async throws -> CreditStatistics {
        let dto = try await creditRepo.statistics(creditId: creditId)
        return CreditStatisticsMapper.toDomain(dto)
    }
}


