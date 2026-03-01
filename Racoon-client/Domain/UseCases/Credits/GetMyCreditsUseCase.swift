//
//  GetMyCreditsUseCase.swift
//  Racoon-client
//
//  Created by dark type on 01.03.2026.
//


public protocol GetMyCreditsUseCase: Sendable {
    func callAsFunction() async throws -> [Credit]
}

public struct GetMyCreditsUseCaseImpl: GetMyCreditsUseCase {
    private let creditRepo: CreditRepository

    public init(creditRepo: CreditRepository) { self.creditRepo = creditRepo }

    public func callAsFunction() async throws -> [Credit] {
        let dtos = try await creditRepo.getMyCredits()
        return dtos.map(CreditMapper.toDomain)
    }
}