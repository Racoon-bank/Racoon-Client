//
//  Money.swift
//  Racoon-client
//
//  Created by dark type on 26.02.2026.
//
import Foundation

public struct Money: Equatable, Sendable {
    public let amount: Decimal
    public init(_ amount: Decimal) { self.amount = amount }
}
