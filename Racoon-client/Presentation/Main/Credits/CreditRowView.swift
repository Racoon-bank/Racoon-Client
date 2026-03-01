//
//  CreditRowView.swift
//  Racoon-client
//
//  Created by dark type on 01.03.2026.
//

import SwiftUI

struct CreditRowView: View {
    let credit: Credit

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(credit.tariffName)
                    .font(.headline)

                Spacer()

                StatusPill(status: credit.status)
            }

            HStack(spacing: 12) {
                Metric(title: "Remaining", value: money(credit.remainingAmount))
                Spacer()
                Metric(title: "Monthly", value: money(credit.monthlyPayment))
            }

            if showsNextPayment(credit.status) {
                HStack {
                    Text("Next payment")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(date(credit.nextPaymentDate))
                        .foregroundStyle(.secondary)
                }
                .font(.caption)
            }
        }
        .padding(.vertical, 6)
    }

    private func money(_ value: Decimal) -> String {
        MoneyFormatter.shared.string(from: value)
    }
    private func showsNextPayment(_ status: CreditStatus) -> Bool {
        switch status {
        case .active, .overdue:
            return true
        case .paidOff, .cancelled:
            return false
        }
    }

    private func date(_ value: Date) -> String {
        value.formatted(date: .abbreviated, time: .omitted)
    }
}

 

 
