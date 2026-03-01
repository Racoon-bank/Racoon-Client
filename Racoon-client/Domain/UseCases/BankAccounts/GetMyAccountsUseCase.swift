//
//  GetMyAccountsUseCase.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import Foundation

public protocol GetMyAccountsUseCase: Sendable {
    func callAsFunction() async throws -> [BankAccount]
}

public struct GetMyAccountsUseCaseImpl: GetMyAccountsUseCase {
    private let repo: CoreBankAccountRepository
    

    public init(repo: CoreBankAccountRepository) {
        self.repo = repo
    }

    public func callAsFunction() async throws -> [BankAccount] {
        let dtos = try await repo.getMyAccounts()
        return dtos.map(BankAccountMapper.toDomain)
    }
}
