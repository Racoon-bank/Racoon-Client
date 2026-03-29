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
public protocol GetMyCreditRatingUseCase: Sendable {
    func callAsFunction() async throws -> CreditRating
}

public struct GetMyCreditRatingUseCaseImpl: GetMyCreditRatingUseCase {
    private let repo: CreditRepository
    public init(repo: CreditRepository) { self.repo = repo }
    
    public func callAsFunction() async throws -> CreditRating {
        let dto = try await repo.getMyCreditRating()
        return CreditMapper.toDomain(dto)
    }
}

// MARK: - Get Applications
public protocol GetMyCreditApplicationsUseCase: Sendable {
    func callAsFunction() async throws -> [CreditApplication]
}

public struct GetMyCreditApplicationsUseCaseImpl: GetMyCreditApplicationsUseCase {
    private let repo: CreditRepository
    public init(repo: CreditRepository) { self.repo = repo }
    
    public func callAsFunction() async throws -> [CreditApplication] {
        let dtos = try await repo.getMyApplications()
        return dtos.map(CreditMapper.toDomain)
    }
}

// MARK: - Get Overdue Payments
public protocol GetMyOverduePaymentsUseCase: Sendable {
    func callAsFunction() async throws -> [OverduePayment]
}

public struct GetMyOverduePaymentsUseCaseImpl: GetMyOverduePaymentsUseCase {
    private let repo: CreditRepository
    public init(repo: CreditRepository) { self.repo = repo }
    
    public func callAsFunction() async throws -> [OverduePayment] {
        let dtos = try await repo.getMyOverduePayments()
        return dtos.map(CreditMapper.toDomain)
    }
}


