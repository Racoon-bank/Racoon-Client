//
//  CreditStatisticsDto.swift
//  Racoon-client
//
//  Created by dark type on 01.03.2026.
//


public struct CreditStatisticsDto: Decodable, Sendable {
    public let creditId: Int64
    public let originalAmount: Double
    public let monthlyPayment: Double
    public let durationMonths: Int
    public let interestRate: Double
    public let totalToRepay: Double
    public let totalInterest: Double
    public let totalPaid: Double?
}
