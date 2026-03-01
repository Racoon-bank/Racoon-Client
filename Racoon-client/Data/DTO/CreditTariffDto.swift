//
//  CreditTariffDto.swift
//  Racoon-client
//
//  Created by dark type on 01.03.2026.
//

import Foundation

public struct CreditTariffDto: Decodable, Sendable {
    public let id: Int64
    public let name: String
    public let interestRate: Double
    public let dueDate: Date
    public let isActive: Bool
    public let createdAt: Date
}
