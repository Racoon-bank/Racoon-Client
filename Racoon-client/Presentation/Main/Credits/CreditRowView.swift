//
//  CreditRowView.swift
//  Racoon-client
//
//  Created by dark type on 01.03.2026.
//

import SwiftUI

struct CreditRowView: View {
    let credit: Credit

    private var isInactive: Bool {
        credit.status == .paidOff || credit.status == .cancelled || credit.nextPaymentDate == nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(credit.tariffName)
                    .font(.headline)
                    .foregroundStyle(isInactive ? .secondary : .primary)

                Spacer()

                StatusPill(status: credit.status)
            }

            HStack(spacing: 12) {
                Metric(title: "Remaining", value: money(credit.remainingAmount))
                Spacer()
                Metric(title: "Monthly", value: money(credit.monthlyPayment))
            }
            .foregroundStyle(isInactive ? .secondary : .primary)

            if showsNextPayment(credit.status), let nextDate = credit.nextPaymentDate {
                HStack {
                    Text("Next payment")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(date(nextDate))
                        .foregroundStyle(.secondary)
                }
                .font(.caption)
            }
        }
        .padding(.vertical, 6)
        .opacity(isInactive ? 0.6 : 1.0)
        .disabled(isInactive)
    }

    private func money(_ value: Decimal) -> String {
        return "\(MoneyFormatter.shared.string(from: value)) \(credit.currency.symbol)"
    }
    
    private func showsNextPayment(_ status: CreditStatus) -> Bool {
        switch status {
        case .active, .overdue:
            return true
        case .paidOff, .cancelled:
            return false
        }
    }

    private func date(_ value: Date?) -> String {
        guard let value = value else { return "—" }
        return value.formatted(date: .abbreviated, time: .omitted)
    }
}
 
