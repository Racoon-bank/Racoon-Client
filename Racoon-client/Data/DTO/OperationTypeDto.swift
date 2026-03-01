//
//  OperationTypeDto.swift
//  Racoon-client
//
//  Created by dark type on 26.02.2026.
//

import Foundation

public enum OperationTypeDto: Decodable, Sendable, Equatable {
    case deposit
    case withdraw
    case creditIssued
    case creditPayment
    case unknown(String)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let s = try container.decode(String.self)

        switch s {
        case "Deposit": self = .deposit
        case "Withdraw": self = .withdraw
        case "CreditIssued": self = .creditIssued
        case "CreditPayment": self = .creditPayment
        default: self = .unknown(s)
        }
    }
}
