//
//  RepayCreditRequestDto.swift
//  Racoon-client
//
//  Created by dark type on 26.02.2026.
//


public struct RepayCreditRequestDto: Encodable, Sendable {
    public let bankAccountId: String
    public let amount: Double

    public init(bankAccountId: String, amount: Double) {
        self.bankAccountId = bankAccountId
        self.amount = amount
    }
}
