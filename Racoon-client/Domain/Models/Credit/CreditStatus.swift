//
//  CreditStatus.swift
//  Racoon-client
//
//  Created by dark type on 26.02.2026.
//


public enum CreditStatus: String, Sendable, Codable {
    case active = "ACTIVE"
    case paidOff = "PAID_OFF"
    case overdue = "OVERDUE"
    case cancelled = "CANCELLED"
}
public extension CreditStatus {
    var title: String {
        switch self {
        case .active: return "Active"
        case .paidOff: return "Paid off"
        case .overdue: return "Overdue"
        case .cancelled: return "Cancelled"
        }
    }
}
