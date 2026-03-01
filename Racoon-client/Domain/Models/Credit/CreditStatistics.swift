//
//  CreditStatistics.swift
//  Racoon-client
//
//  Created by dark type on 01.03.2026.
//


import Foundation

public struct CreditStatistics: Sendable {
    public let creditId: Int64
    public let originalAmount: Decimal
    public let monthlyPayment: Decimal
    public let durationMonths: Int
    public let interestRate: Decimal
    public let totalToRepay: Decimal
    public let totalInterest: Decimal
}
