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
    private let hiddenStorage: AppSettingsStorage

    public init(repo: CoreBankAccountRepository, hiddenStorage: AppSettingsStorage) {
        self.repo = repo
        self.hiddenStorage = hiddenStorage
    }

    public func callAsFunction() async throws -> [BankAccount] {
        let dtos = try await repo.getMyAccounts()
        let hiddenIds = hiddenStorage.load().hiddenAccountIds
        
        return dtos.map { BankAccountMapper.toDomain($0, hiddenAccountIds: hiddenIds) }
    }
}
