//
//  CreateBankAccountDto.swift
//  Racoon-client
//
//  Created by dark type on 22.03.2026.
//


public struct CreateBankAccountDto: Encodable, Sendable {
    public let currency: String
    
    public init(currency: String) {
        self.currency = currency
    }
}