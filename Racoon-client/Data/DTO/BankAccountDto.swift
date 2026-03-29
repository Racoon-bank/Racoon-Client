//
//  BankAccountDto.swift
//  Racoon-client
//
//  Created by dark type on 26.02.2026.
//

import Foundation

public struct BankAccountDto: Decodable, Sendable {
    public let id: UUID
    public let userId: UUID
    public let accountNumber: String?
    public let balance: Double
    public let createdAt: Date
    public let currency: String
}
