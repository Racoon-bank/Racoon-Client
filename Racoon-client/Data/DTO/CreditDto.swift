//
//  CreditDto.swift
//  Racoon-client
//
//  Created by dark type on 26.02.2026.
//

import Foundation

public struct CreditDto: Decodable, Sendable {
    public let id: Int64
    public let ownerId: String
    public let tariffId: Int64
    public let tariffName: String
    public let interestRate: Double
    public let currency: Currency
    public let amount: Double
    public let remainingAmount: Double
    public let monthlyPayment: Double
    public let totalAmount: Double
    public let durationMonths: Int
    public let remainingMonths: Int
    public let accumulatedPenalty: Double
    public let overdueDays: Int
    public let status: String
    public let issueDate: Date
    
    public let nextPaymentDate: Date?
    
    public let createdAt: Date
    public let updatedAt: Date
}
