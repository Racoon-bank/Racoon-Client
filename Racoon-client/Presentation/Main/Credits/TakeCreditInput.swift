//
//  TakeCreditInput.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import SwiftUI

struct TakeCreditInput: Sendable {
    let bankAccountId: UUID
    let tariffId: Int64
    let amount: Decimal
    let durationMonths: Int
}
