//
//  CreditPaymentType.swift
//  Racoon-client
//
//  Created by dark type on 26.02.2026.
//


public enum CreditPaymentType: String, Sendable, Codable {
    case manualRepayment = "MANUAL_REPAYMENT"
    case automaticDaily = "AUTOMATIC_DAILY"
    case earlyRepayment = "EARLY_REPAYMENT"
    case penalty = "PENALTY"
}
