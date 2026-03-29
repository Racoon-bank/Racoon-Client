//
//  CoreBankAccountRepository.swift
//  Racoon-client
//
//  Created by dark type on 26.02.2026.
//

import Foundation

public protocol CoreBankAccountRepository: Sendable {
    func openAccount(currency: String) async throws -> BankAccountDto
    func changeVisibility(id: UUID) async throws
    func transfer(fromAccountId: UUID, toAccountNumber: String?, amount: Double) async throws 
    func closeAccount(id: UUID) async throws
    func getMyAccounts() async throws -> [BankAccountDto]
    func deposit(id: UUID, amount: Double) async throws -> BankAccountDto
    func withdraw(id: UUID, amount: Double) async throws -> BankAccountDto
    func history(id: UUID) async throws -> [BankAccountOperationDto]
}
