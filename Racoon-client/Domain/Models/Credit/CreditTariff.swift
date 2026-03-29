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
public struct CreditRating: Sendable {
    public let score: Int
    public let ratingLevel: String
}

public enum CreditApplicationStatus: String, Sendable {
    case pending = "PENDING"
    case approved = "APPROVED"
    case rejected = "REJECTED"
}

public struct CreditApplication: Identifiable, Sendable {
    public let id: Int64
    public let tariffName: String
    public let amount: Decimal
    public let status: CreditApplicationStatus
}

public struct OverduePayment: Identifiable, Sendable {
    public var id: Int64 { scheduleId }
    public let scheduleId: Int64
    public let creditId: Int64
    public let remainingDue: Decimal
    public let overdueDays: Int
}

public struct TakeCreditResult: Sendable {
    public let message: String?
    public let credit: Credit?
    public let application: CreditApplication?
}
