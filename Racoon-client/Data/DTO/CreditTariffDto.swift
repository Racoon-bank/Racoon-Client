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
public struct CreditRatingDto: Decodable, Sendable {
    public let score: Int
    public let ratingLevel: String?
}

public struct CreditApplicationDto: Decodable, Sendable {
    public let id: Int64
    public let tariffName: String?
    public let amount: Double
    public let status: String?
}

public struct OverduePaymentDto: Decodable, Sendable {
    public let scheduleId: Int64
    public let creditId: Int64
    public let remainingDue: Double
    public let overdueDays: Int
}

public struct TakeCreditResultDto: Decodable, Sendable {
    public let resultType: String?
    public let message: String?
    public let credit: CreditDto?
    public let application: CreditApplicationDto?
}
