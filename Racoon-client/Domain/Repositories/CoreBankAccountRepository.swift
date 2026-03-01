//
//  CoreBankAccountRepository.swift
//  Racoon-client
//
//  Created by dark type on 26.02.2026.
//

import Foundation

public protocol CoreBankAccountRepository: Sendable {
    func openAccount() async throws -> BankAccountDto
    func closeAccount(id: UUID) async throws
    func getMyAccounts() async throws -> [BankAccountDto]
    func deposit(id: UUID, amount: Double) async throws -> BankAccountDto
    func withdraw(id: UUID, amount: Double) async throws -> BankAccountDto
    func history(id: UUID) async throws -> [BankAccountOperationDto]
}
