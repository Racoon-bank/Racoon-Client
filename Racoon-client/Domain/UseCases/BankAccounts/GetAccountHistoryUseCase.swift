//
//  GetAccountHistoryUseCase.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import Foundation

public protocol GetAccountHistoryUseCase: Sendable {
    func callAsFunction(accountId: UUID) async throws -> [BankOperation]
}

public struct GetAccountHistoryUseCaseImpl: GetAccountHistoryUseCase {
    private let repo: CoreBankAccountRepository
    

    public init(repo: CoreBankAccountRepository) {
        self.repo = repo
    }

    public func callAsFunction(accountId: UUID) async throws -> [BankOperation] {
        let dtos = try await repo.history(id: accountId)
        return dtos.map(BankAccountMapper.toDomain)
    }
}
