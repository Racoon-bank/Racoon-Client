//
//  BankOperationType.swift
//  Racoon-client
//
//  Created by dark type on 26.02.2026.
//


public enum BankOperationType: Sendable, Equatable {
    case deposit
    case withdraw
    case creditIssued
    case creditPayment
    case unknown(String)
}
