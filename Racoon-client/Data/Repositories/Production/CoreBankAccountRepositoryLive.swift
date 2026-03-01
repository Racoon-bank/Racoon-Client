//
//  CoreBankAccountRepositoryLive.swift
//  Racoon-client
//
//  Created by dark type on 26.02.2026.
//

import Foundation

public final class CoreBankAccountRepositoryLive: CoreBankAccountRepository {
    private let client: HTTPClient
    public init(client: HTTPClient) { self.client = client }

    public func openAccount() async throws -> BankAccountDto {
        try await client.send(CoreRouter.openAccount, as: BankAccountDto.self)
    }

    public func closeAccount(id: UUID) async throws {
        try await client.sendNoResponse(CoreRouter.closeAccount(id: id))
    }

    public func getMyAccounts() async throws -> [BankAccountDto] {
        try await client.send(CoreRouter.myAccounts, as: [BankAccountDto].self)
    }

    public func deposit(id: UUID, amount: Double) async throws -> BankAccountDto {
        try await client.send(CoreRouter.deposit(id: id, amount: amount), as: BankAccountDto.self)
    }

    public func withdraw(id: UUID, amount: Double) async throws -> BankAccountDto {
        try await client.send(CoreRouter.withdraw(id: id, amount: amount), as: BankAccountDto.self)
    }

    public func history(id: UUID) async throws -> [BankAccountOperationDto] {
        try await client.send(CoreRouter.history(id: id), as: [BankAccountOperationDto].self)
    }
}
