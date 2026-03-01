//
//  PaymentScheduleItem.swift
//  Racoon-client
//
//  Created by dark type on 01.03.2026.
//


import Foundation

public struct PaymentScheduleItem: Sendable, Identifiable {
    public let id: Int64
    public let creditId: Int64
    public let monthNumber: Int
    public let paymentDate: Date
    public let totalPayment: Decimal
    public let interestPayment: Decimal
    public let principalPayment: Decimal
    public let remainingBalance: Decimal
    public let paid: Bool
}

public enum PaymentScheduleStatus: String, Sendable, Equatable {
    case pending = "PENDING"
    case paid = "PAID"
    case overdue = "OVERDUE"
}
