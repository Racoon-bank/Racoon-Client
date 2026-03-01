//
//  CreditPaymentDto.swift
//  Racoon-client
//
//  Created by dark type on 26.02.2026.
//

import Foundation

public struct CreditPaymentDto: Decodable, Sendable {
    public let id: Int64
    public let creditId: Int64
    public let amount: Double
    public let paymentType: CreditPaymentType
    public let paymentDate: Date
    public let createdAt: Date
}
