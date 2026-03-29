//
//  CreditDetailsView.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import SwiftUI
import Foundation


struct CreditDetailsView: View {
    @StateObject private var viewModel: CreditDetailsViewModel
    let creditId: Int64

    @State private var showRepaySheet = false

    init(viewModel: CreditDetailsViewModel, creditId: Int64) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.creditId = creditId
    }

    var body: some View {
        List {
            summarySection
            statsSection
            scheduleSection

            repaySection

            paymentsSection
            technicalDetailsSection
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Credit")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if viewModel.state.isLoading { ProgressView().controlSize(.small) }
            }
        }
        .task { await viewModel.load() }
        .refreshable { await viewModel.refresh() }
        .sheet(isPresented: $showRepaySheet) {
            RepayCreditSheet(
                remainingAmount: viewModel.credit?.remainingAmount ?? 0,
                accountsState: viewModel.accountsState,
                onRetry: { Task { await viewModel.retryAccounts() } },
                onConfirm: { input in
                    Task { await viewModel.repayCredit(bankAccountId: input.bankAccountId, amount: input.amount) }
                }
            )
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.state.errorMessage != nil },
            set: { shown in if !shown { viewModel.clearError() } }
        )) {
            Button("OK", role: .cancel) { viewModel.clearError() }
        } message: {
            Text(viewModel.state.errorMessage ?? "")
        }
    }
}

// MARK: Sections

private extension CreditDetailsView {
    var summarySection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(viewModel.credit?.tariffName ?? "Credit")
                        .font(.headline)
                    Spacer()
                    if let status = viewModel.credit?.status {
                        StatusPill(status: status)
                    }
                }

                HStack(spacing: 12) {
                    Metric(title: "Remaining", value: money(viewModel.credit?.remainingAmount))
                    Spacer()
                    Metric(title: "Monthly", value: money(viewModel.credit?.monthlyPayment))
                }

                if let credit = viewModel.credit,
                             showsNextPayment(credit.status),
                             let nextDate = credit.nextPaymentDate {
                              
                              HStack {
                                  Text("Next payment").foregroundStyle(.secondary)
                                  Spacer()
                                  Text(nextDate.formatted(date: .abbreviated, time: .omitted))
                                      .foregroundStyle(.secondary)
                              }
                              .font(.caption)
                          }
            }
            .padding(.vertical, 6)
        }
    }
    private func showsNextPayment(_ status: CreditStatus) -> Bool {
        status == .active || status == .overdue
    }

    var statsSection: some View {
        Section("Statistics") {
            if let s = viewModel.statistics {
                LabeledContent("Original amount", value: money(s.originalAmount))
                LabeledContent("Monthly payment", value: money(s.monthlyPayment))
                LabeledContent("Duration (months)", value: "\(s.durationMonths)")
                LabeledContent("Interest rate", value: percent(s.interestRate))
                LabeledContent("Total to repay", value: money(s.totalToRepay))
                LabeledContent("Total interest", value: money(s.totalInterest))
            } else {
                Text("No statistics yet.")
                    .foregroundStyle(.secondary)
            }
        }
    }

    var scheduleSection: some View {
        Section("Schedule") {
            if viewModel.schedule.isEmpty {
                Text("No schedule available.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.schedule) { item in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(item.paymentDate.formatted(date: .abbreviated, time: .omitted))
                            Spacer()
                            Text(money(item.totalPayment))
                                .monospacedDigit()
                        }

                        HStack(spacing: 10) {
                            Text(item.paid ? "Paid" : "Pending")
                                .font(.caption)
                                .foregroundStyle(item.paid ? .green : .secondary)

                            Text("Principal: \(money(item.principalPayment))")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Text("Interest: \(money(item.interestPayment))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Text("Remaining: \(money(item.remainingBalance))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    var repaySection: some View {
        Section {
            Button("Make a payment") { showRepaySheet = true }
                .disabled(!canPayNow || viewModel.state.isLoading)
        } footer: {
            switch viewModel.accountsState {
            case .idle:
                Text("Accounts are not loaded yet.")
                    .foregroundStyle(.secondary)
            case .loading:
                Text("Loading accounts…")
                    .foregroundStyle(.secondary)
            case .loaded(let accounts):
                if accounts.isEmpty {
                    Text("No accounts available. Create a bank account first.")
                        .foregroundStyle(.secondary)
                } else {
                    Text("Choose an account and enter the amount.")
                        .foregroundStyle(.secondary)
                }
            case .failed(let message):
                Text(message)
                    .foregroundStyle(.secondary)
            }
        }
    }

    var paymentsSection: some View {
        Section("Payments") {
            if viewModel.payments.isEmpty {
                Text("No payments yet.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.payments) { p in
                    PaymentRow(payment: p)
                }
            }
        }
    }

    var technicalDetailsSection: some View {
        Section {
            DisclosureGroup("Technical details") {
                LabeledContent("Credit ID", value: "\(creditId)")
                if let owner = viewModel.credit?.ownerId {
                    LabeledContent("Owner ID", value: owner.uuidString)
                }
            }
        }
    }

    var canPayNow: Bool {
        if case .loaded(let a) = viewModel.accountsState {
            return !a.isEmpty
        }
        return false
    }

    func money(_ value: Decimal?) -> String {
        guard let value else { return "—" }
        return MoneyFormatter.shared.string(from: value)
    }

    func date(_ value: Date?) -> String {
        guard let value else { return "—" }
        return value.formatted(date: .abbreviated, time: .omitted)
    }
    private func percent(_ value: Decimal) -> String {
        let number = NSDecimalNumber(decimal: value * 100)
        return number.stringValue + " %"
    }
}
