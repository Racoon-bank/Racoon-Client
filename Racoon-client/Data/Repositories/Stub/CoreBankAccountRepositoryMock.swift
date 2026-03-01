//
//  CoreBankAccountRepositoryMock.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import Foundation

public final class CoreBankAccountRepositoryMock: CoreBankAccountRepository {
    private let db: MockDatabase

    public init(db: MockDatabase = .shared) {
        self.db = db
    }

    public func getMyAccounts() async throws -> [BankAccountDto] {
        await db.getMyAccounts()
    }

    public func openAccount() async throws -> BankAccountDto {
        await db.openAccount()
    }

    public func closeAccount(id: UUID) async throws {
        try await db.closeAccount(id: id)
    }

    public func deposit(id: UUID, amount: Double) async throws -> BankAccountDto {
        try await db.deposit(id: id, amount: amount)
    }

    public func withdraw(id: UUID, amount: Double) async throws -> BankAccountDto {
        try await db.withdraw(id: id, amount: amount)
    }

    public func history(id: UUID) async throws -> [BankAccountOperationDto] {
        try await db.history(id: id)
    }
}
