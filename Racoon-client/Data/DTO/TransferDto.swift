//
//  TransferDto.swift
//  Racoon-client
//
//  Created by dark type on 22.03.2026.
//

import Foundation

public struct TransferDto: Encodable, Sendable {
    public let fromAccountId: UUID
    public let toAccountNumber: String?
    public let amount: Double
    
    public init(fromAccountId: UUID, toAccountNumber: String?, amount: Double) {
        self.fromAccountId = fromAccountId
        self.toAccountNumber = toAccountNumber
        self.amount = amount
    }
}
