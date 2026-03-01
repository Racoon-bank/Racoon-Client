//
//  PaymentScheduleDto.swift
//  Racoon-client
//
//  Created by dark type on 01.03.2026.
//

import Foundation

public struct PaymentScheduleDto: Decodable, Sendable {
    public let id: Int64
    public let creditId: Int64
    public let monthNumber: Int
    public let paymentDate: Date
    public let totalPayment: Double
    public let interestPayment: Double
    public let principalPayment: Double
    public let remainingBalance: Double
    public let paid: Bool
}
