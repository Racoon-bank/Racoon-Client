//
//  TakeCreditRequestDto.swift
//  Racoon-client
//
//  Created by dark type on 26.02.2026.
//


public struct TakeCreditRequestDto: Encodable, Sendable {
    public let bankAccountId: String
    public let tariffId: Int64
    public let amount: Double
    public let durationMonths: Int

    public init(bankAccountId: String, tariffId: Int64, amount: Double, durationMonths: Int) {
        self.bankAccountId = bankAccountId
        self.tariffId = tariffId
        self.amount = amount
        self.durationMonths = durationMonths
    }
}
