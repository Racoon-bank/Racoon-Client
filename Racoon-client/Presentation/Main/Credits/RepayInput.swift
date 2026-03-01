//
//  RepayInput.swift
//  Racoon-client
//
//  Created by dark type on 01.03.2026.
//

import Foundation

struct RepayInput: Sendable {
    let bankAccountId: UUID
    let amount: Decimal
}
