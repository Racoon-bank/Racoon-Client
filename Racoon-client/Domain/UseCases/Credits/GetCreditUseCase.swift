//
//  GetCreditUseCase.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import Foundation

public protocol GetCreditUseCase: Sendable {
    func callAsFunction(creditId: Int64) async throws -> Credit
}

public struct GetCreditUseCaseImpl: GetCreditUseCase {
    private let creditRepo: CreditRepository

    public init(creditRepo: CreditRepository) { self.creditRepo = creditRepo }

    public func callAsFunction(creditId: Int64) async throws -> Credit {
        let dto = try await creditRepo.get(creditId: creditId)
        return CreditMapper.toDomain(dto)
    }
}
