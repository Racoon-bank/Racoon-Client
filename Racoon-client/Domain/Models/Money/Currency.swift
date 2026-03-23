//
//  Currency.swift
//  Racoon-client
//
//  Created by dark type on 22.03.2026.
//


public enum Currency: String, Codable, Sendable {
    case RUB = "RUB"
    case USD = "USD"
    case EUR = "EUR"
}
extension Currency {
    var symbol: String {
        switch self {
        case .RUB: return "₽"
        case .USD: return "$"
        case .EUR: return "€"
        }
    }

    var title: String {
        switch self {
        case .RUB: return "Russian ruble"
        case .USD: return "US dollar"
        case .EUR: return "Euro"
        }
    }

    var shortDisplay: String {
        "\(symbol) \(rawValue)"
    }
}
extension Currency {
    init(dtoValue: String) {
        self = Currency(rawValue: dtoValue) ?? .RUB
    }
}
