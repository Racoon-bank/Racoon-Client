//
//  StatusPill.swift
//  Racoon-client
//
//  Created by dark type on 01.03.2026.
//


import SwiftUI

struct StatusPill: View {
    let status: CreditStatus

    var body: some View {
        Text(status.title)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(.thinMaterial)
            .clipShape(Capsule())
    }
}