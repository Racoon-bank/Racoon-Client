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
    @State private var showTransferSheet = false
    @State private var showCloseConfirm = false

    init(viewModel: AccountDetailsViewModel, accountId: UUID) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.accountId = accountId
    }

    var body: some View {
        List {
            Section("Account") {
                LabeledContent("ID", value: accountId.uuidString.prefix(8) + "…")
                if let account = viewModel.account {
                    LabeledContent("Balance", value: formatMoney(account.balance, currency: account.currency))
                    LabeledContent("Status", value: account.isHidden ? "Hidden" : "Visible")
                }
            }

            Section {
                Button("Deposit") { showDepositSheet = true }
                    .disabled(viewModel.state.isLoading)

                Button("Withdraw") { showWithdrawSheet = true }
                    .disabled(viewModel.state.isLoading)
                    
                Button("Transfer") { showTransferSheet = true }
                    .disabled(viewModel.state.isLoading)
            }

            Section {
                if let account = viewModel.account {
                    Button(account.isHidden ? "Reveal account" : "Hide account") {
                        Task { await viewModel.toggleVisibility() }
                    }
                    .disabled(viewModel.state.isLoading)
                }

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
                       if viewModel.state.isLoading { ProgressView().controlSize(.small) }
                   }
               }
               .onAppear {
                   Task { await viewModel.load() }
               }
               .task {
                   await viewModel.observeEvents()
               }
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
        .sheet(isPresented: $showTransferSheet) {
            TransferInputSheet { targetAccount, amount in
                Task { await viewModel.makeTransfer(to: targetAccount, amount: amount) }
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
    
    private func formatMoney(_ value: Decimal, currency: Currency) -> String {
        let number = NSDecimalNumber(decimal: value)
        return "\(number.stringValue) \(currency.symbol)"
    }
}

private struct OperationRow: View {
    let op: BankOperation

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(operationTitle(for: op.type))
                    .font(.headline)
                Spacer()
                Text(NSDecimalNumber(decimal: op.amount).stringValue)
                    .monospacedDigit()
                    .foregroundStyle(amountColor(for: op.type))
            }
            Text(op.createdAt.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }
    
    private func operationTitle(for type: BankOperationType) -> String {
        switch type {
        case .deposit: return "Deposit"
        case .withdraw: return "Withdraw"
        case .creditIssued: return "Credit Issued"
        case .creditPayment: return "Credit Payment"
        case .unknown: return "Transfer"
        }
    }
    
    private func amountColor(for type: BankOperationType) -> Color {
        switch type {
        case .deposit, .creditIssued: return .green
        case .withdraw, .creditPayment: return .primary
        case .unknown: return .primary
        }
    }
}

struct TransferInputSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var amountString = ""
    @State private var targetAccount = ""
    
    let onConfirm: (String, Decimal) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Recipient") {
                    TextField("Account Number", text: $targetAccount)
                        .keyboardType(.asciiCapable)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
                
                Section("Amount") {
                    TextField("0.00", text: $amountString)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Transfer Money")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Send") {
                        if let amount = Decimal(string: amountString.replacingOccurrences(of: ",", with: ".")), amount > 0, !targetAccount.isEmpty {
                            onConfirm(targetAccount, amount)
                            dismiss()
                        }
                    }
                    .disabled(amountString.isEmpty || targetAccount.isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
