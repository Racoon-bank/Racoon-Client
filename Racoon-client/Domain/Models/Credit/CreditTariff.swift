//
//  CreditTariff.swift
//  Racoon-client
//
//  Created by dark type on 01.03.2026.
//


import Foundation

public struct CreditTariff: Sendable, Identifiable {
    public let id: Int64
    public let name: String
    public let interestRate: Decimal
    public let dueDate: Date
    public let isActive: Bool
    public let createdAt: Date
}
