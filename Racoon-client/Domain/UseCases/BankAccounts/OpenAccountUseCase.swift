//
//  OpenAccountUseCase.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import Foundation

public protocol OpenAccountUseCase: Sendable {
    func callAsFunction() async throws -> BankAccount
}

public struct OpenAccountUseCaseImpl: OpenAccountUseCase {
    private let repo: CoreBankAccountRepository

    public init(repo: CoreBankAccountRepository) {
        self.repo = repo
    }

    public func callAsFunction() async throws -> BankAccount {
        let dto = try await repo.openAccount()
        return BankAccountMapper.toDomain(dto)
    }
}
