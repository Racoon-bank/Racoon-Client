//
//  BankOperation.swift
//  Racoon-client
//
//  Created by dark type on 26.02.2026.
//

import Foundation

public struct BankOperation: Equatable, Sendable, Identifiable {
    public let id: UUID
    public let amount: Decimal
    public let type: BankOperationType
    public let createdAt: Date
}
