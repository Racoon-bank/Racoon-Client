//
//  PaymentRow.swift
//  Racoon-client
//
//  Created by dark type on 01.03.2026.
//

import SwiftUI

struct PaymentRow: View {
    let payment: CreditPayment

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(paymentTitle(payment.paymentType))
                    .font(.headline)
                Spacer()
                Text(MoneyFormatter.shared.string(from: payment.amount))
                    .monospacedDigit()
            }
            Text(payment.paymentDate.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }

    private func paymentTitle(_ type: CreditPaymentType) -> String {
        switch type {
        case .manualRepayment: return "Payment"
        case .automaticDaily: return "Auto payment"
        case .earlyRepayment: return "Early payment"
        case .penalty: return "Penalty"
        }
    }
}
