//
//  AccountDetailsView.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import SwiftUI

struct AccountDetailsView: View {
    @StateObject private var viewModel: AccountDetailsViewModel
    let accountId: UUID

    @Environment(\.dismiss) private var dismiss
    @State private var showDepositSheet = false
    @State private var showWithdrawSheet = false
    @State private var showCloseConfirm = false

    init(viewModel: AccountDetailsViewModel, accountId: UUID) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.accountId = accountId
    }

    var body: some View {
        List {
            Section("Account") {
                LabeledContent("ID", value: accountId.uuidString.prefix(8) + "…")
                LabeledContent("Balance", value: Formatters.money(viewModel.account?.balance))
            }

            Section {
                Button("Deposit") { showDepositSheet = true }
                    .disabled(viewModel.state.isLoading)

                Button("Withdraw") { showWithdrawSheet = true }
                    .disabled(viewModel.state.isLoading)
            }

            Section {
                Button(role: .destructive) {
                    showCloseConfirm = true
                } label: {
                    Text("Close account")
                }
                .disabled(viewModel.state.isLoading)
            }

            Section("History") {
                if viewModel.history.isEmpty {
                    Text("No operations yet.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.history) { op in
                        OperationRow(op: op)
                    }
                }
            }
        }
        .navigationTitle("Account")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if viewModel.state.isLoading {
                    ProgressView().controlSize(.small)
                }
            }
        }
        .task { await viewModel.load() }
        .refreshable { await viewModel.refresh() }
        .sheet(isPresented: $showDepositSheet) {
            AmountInputSheet(title: "Deposit", confirmTitle: "Add") { amount in
                Task { await viewModel.makeDeposit(amount: amount) }
            }
        }
        .sheet(isPresented: $showWithdrawSheet) {
            AmountInputSheet(title: "Withdraw", confirmTitle: "Take") { amount in
                Task { await viewModel.makeWithdraw(amount: amount) }
            }
        }
        .confirmationDialog(
            "Close this account?",
            isPresented: $showCloseConfirm,
            titleVisibility: .visible
        ) {
            Button("Close account", role: .destructive) {
                Task {
                    let closed = await viewModel.closeThisAccount()
                    if closed { dismiss() }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("All the money left on the account will be donated to poor HITs students.")
        }
        .errorAlert(errorMessage: viewModel.state.errorMessage, clearError: { viewModel.clearError() })
    }
}

private struct OperationRow: View {
    let op: BankOperation

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(op.type == .deposit ? "Deposit" : "Withdraw")
                    .font(.headline)
                Spacer()
                Text(NSDecimalNumber(decimal: op.amount).stringValue)
                    .monospacedDigit()
            }
            Text(op.createdAt.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }
}
