//
//  MoneyFormatter.swift
//  Racoon-client
//
//  Created by dark type on 01.03.2026.
//


import Foundation

final class MoneyFormatter {
    static let shared = MoneyFormatter()

    private let numberFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "RUB"
        f.maximumFractionDigits = 2
        f.minimumFractionDigits = 2
        return f
    }()
    func plainString(from decimal: Decimal) -> String {
        let f = NumberFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.numberStyle = .decimal
        f.usesGroupingSeparator = false
        f.maximumFractionDigits = 2
        f.minimumFractionDigits = 0
        return f.string(from: NSDecimalNumber(decimal: decimal)) ?? NSDecimalNumber(decimal: decimal).stringValue
    }
    func string(from decimal: Decimal) -> String {
        numberFormatter.string(from: NSDecimalNumber(decimal: decimal)) ?? NSDecimalNumber(decimal: decimal).stringValue
    }
}
