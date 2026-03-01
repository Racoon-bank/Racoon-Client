//
//  PaymentScheduleStatusDto.swift
//  Racoon-client
//
//  Created by dark type on 01.03.2026.
//


public enum PaymentScheduleStatusDto: String, Codable, Sendable {
    case pending = "PENDING"
    case paid = "PAID"
    case overdue = "OVERDUE"
}