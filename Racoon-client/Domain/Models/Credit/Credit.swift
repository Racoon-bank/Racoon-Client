//
//  Credit.swift
//  Racoon-client
//
//  Created by dark type on 26.02.2026.
//

import Foundation

public struct Credit: Identifiable, Sendable {
    public let id: Int64
    public let ownerId: UUID

    public let tariffId: Int64
    public let tariffName: String
    public let interestRate: Decimal

    public let amount: Decimal
    public let remainingAmount: Decimal
    public let monthlyPayment: Decimal

    public let durationMonths: Int
    public let remainingMonths: Int

    public let accumulatedPenalty: Decimal
    public let overdueDays: Int

    public let status: CreditStatus

    public let issueDate: Date
    public let nextPaymentDate: Date

    public let createdAt: Date
    public let updatedAt: Date?
}
