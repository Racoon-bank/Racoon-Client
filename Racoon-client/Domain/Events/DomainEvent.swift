//
//  DomainEvent.swift
//  Racoon-client
//
//  Created by dark type on 26.02.2026.
//

import Foundation

public enum DomainEvent: Sendable {
    case userRegistered
    case authLoggedIn
    case authLoggedOut
    case bankAccountOpened(accountId: UUID)
    case bankAccountClosed(accountId: UUID)
    case moneyDeposited(accountId: UUID, amount: Decimal)
    case moneyWithdrawn(accountId: UUID, amount: Decimal)
    case moneyTransferred(fromAccountId: UUID, toAccountNumber: String?, amount: Decimal)
    case creditTaken(creditId: Int64)
    case creditRepaid(creditId: Int64, amount: Decimal)
    case visibilityChanged(accountId: UUID)
    case themeSwitched
}
