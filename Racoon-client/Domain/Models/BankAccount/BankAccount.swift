//
//  BankAccount.swift
//  Racoon-client
//
//  Created by dark type on 26.02.2026.
//

import Foundation

public struct BankAccount: Equatable, Sendable, Identifiable {
    public let id: UUID
    public let userId: UUID
    public let accountNumber: String?
    public let balance: Decimal
    public let createdAt: Date
}
