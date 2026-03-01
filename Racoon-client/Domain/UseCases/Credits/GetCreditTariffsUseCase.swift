//
//  GetCreditTariffsUseCase.swift
//  Racoon-client
//
//  Created by dark type on 01.03.2026.
//


public protocol GetCreditTariffsUseCase: Sendable {
    func callAsFunction() async throws -> [CreditTariff]
}

public struct GetCreditTariffsUseCaseImpl: GetCreditTariffsUseCase {
    private let creditRepo: CreditRepository
    public init(creditRepo: CreditRepository) { self.creditRepo = creditRepo }

    public func callAsFunction() async throws -> [CreditTariff] {
        let dtos = try await creditRepo.tariffs()
        return dtos.map(CreditTariffMapper.toDomain)
    }
}