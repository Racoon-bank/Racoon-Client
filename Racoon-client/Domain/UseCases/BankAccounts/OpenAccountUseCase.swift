//
//  OpenAccountUseCase.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import Foundation

public protocol OpenAccountUseCase: Sendable {
    func callAsFunction(currency: Currency) async throws -> BankAccount
}

public struct OpenAccountUseCaseImpl: OpenAccountUseCase {
    private let repo: CoreBankAccountRepository
    private let hiddenStorage: AppSettingsStorage

    public init(repo: CoreBankAccountRepository, hiddenStorage: AppSettingsStorage) {
        self.repo = repo
        self.hiddenStorage = hiddenStorage
    }

    public func callAsFunction(currency: Currency) async throws -> BankAccount {
        let dto = try await repo.openAccount(currency: currency.rawValue)
        let hiddenIds = hiddenStorage.load().hiddenAccountIds
        
        return BankAccountMapper.toDomain(dto, hiddenAccountIds: hiddenIds) 
    }
}
