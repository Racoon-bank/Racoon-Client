//
//  RepayCreditSheet.swift
//  Racoon-client
//
//  Created by dark type on 01.03.2026.
//


import SwiftUI

struct RepayCreditSheet: View {
    let remainingAmount: Decimal
    let accountsState: Loadable<[BankAccount]>
    let onRetry: () -> Void
    let onConfirm: (RepayInput) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var selectedAccountId: UUID?
    @State private var amountText: String = ""
    @State private var errorText: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Bank account") {
                    accountsPickerContent
                }

                Section("Credit") {
                    LabeledContent("Remaining", value: money(remainingAmount))
                    if let maxPayable = maxPayableAmount {
                        LabeledContent("Max payable now", value: money(maxPayable))
                    } else {
                        Text("Loading max payable…")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Amount") {
                    TextField("Amount", text: $amountText)
                        .keyboardType(.decimalPad)
                        .onChange(of: amountText) { _ in
                            errorText = nil
                        }

                    Button("Pay full remaining") {
                        amountText = MoneyFormatter.shared.plainString(from: maxPayableAmount ?? remainingAmount)
                    }
                    .disabled(maxPayableAmount == nil || (maxPayableAmount ?? 0) <= 0)
                }

                if let validationMessage {
                    Section {
                        Text(validationMessage)
                            .foregroundStyle(.red)
                    }
                } else if let helperMessage {
                    Section {
                        Text(helperMessage)
                            .foregroundStyle(.secondary)
                    }
                }

                if let errorText {
                    Section {
                        Text(errorText)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Payment")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Pay") {
                        guard let input = parseForSubmit() else { return }
                        onConfirm(input)
                        dismiss()
                    }
                    .disabled(!canSubmit)
                }
            }
            .onAppear {
                if selectedAccountId == nil, let first = accountsState.value?.first {
                    selectedAccountId = first.id
                }
            }
            .onChange(of: accountsState.value?.first?.id) { _ in
                if selectedAccountId == nil, let first = accountsState.value?.first {
                    selectedAccountId = first.id
                }
            }
        }
    }

    // MARK: - Picker / states

    @ViewBuilder
    private var accountsPickerContent: some View {
        switch accountsState {
        case .idle, .loading:
            HStack(spacing: 10) {
                ProgressView()
                Text("Loading accounts…")
                    .foregroundStyle(.secondary)
            }

        case .failed(let message):
            VStack(alignment: .leading, spacing: 10) {
                Text(message).foregroundStyle(.secondary)
                Button("Retry") { onRetry() }
            }

        case .loaded(let accounts):
            if accounts.isEmpty {
                Text("No accounts available. Create a bank account first.")
                    .foregroundStyle(.secondary)
            } else {
                Picker("Account", selection: $selectedAccountId) {
                    ForEach(accounts) { a in
                        Text("\(a.accountNumber) • \(money(a.balance))")
                            .tag(Optional(a.id))
                    }
                }
                .onChange(of: selectedAccountId) { _ in
                    errorText = nil
                }
            }
        }
    }

    // MARK: - Validation

    private var selectedAccount: BankAccount? {
        guard let id = selectedAccountId else { return nil }
        return accountsState.value?.first(where: { $0.id == id })
    }

    private var maxPayableAmount: Decimal? {
        guard let acc = selectedAccount else { return nil }
        return min(remainingAmount, acc.balance)
    }

    private func parseAmount() -> Decimal? {
        let trimmed = amountText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let noSpaces = trimmed.replacingOccurrences(of: " ", with: "")

        let posix = NumberFormatter()
        posix.locale = Locale(identifier: "en_US_POSIX")
        posix.numberStyle = .decimal
        posix.usesGroupingSeparator = false
        posix.decimalSeparator = "."
        posix.groupingSeparator = ","

        if let n = posix.number(from: noSpaces.replacingOccurrences(of: ",", with: "")) {
            return n.decimalValue
        }
        let local = NumberFormatter()
        local.locale = Locale.current
        local.numberStyle = .decimal
        local.usesGroupingSeparator = true

        if let n = local.number(from: noSpaces) {
            return n.decimalValue
        }

        let heuristic = noSpaces
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: ".")

        if let n = posix.number(from: heuristic) {
            return n.decimalValue
        }

        return nil
    }

    private var validationMessage: String? {
        guard selectedAccountId != nil else { return nil }
        guard let maxPayable = maxPayableAmount else { return nil }

        let trimmed = amountText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return nil }

        guard let amount = parseAmount() else { return "Enter a valid amount." }
        if amount <= 0 { return "Amount must be greater than zero." }

        if amount > remainingAmount {
            return "Amount exceeds remaining credit balance (\(money(remainingAmount)))."
        }

        if amount > maxPayable {
            return "Insufficient funds. Max payable now: \(money(maxPayable))."
        }

        return nil
    }

    private var helperMessage: String? {
        guard let acc = selectedAccount else { return nil }
        return "Available: \(money(acc.balance))"
    }

    private var canSubmit: Bool {
        guard selectedAccountId != nil else { return false }
        guard let amount = parseAmount(), amount > 0 else { return false }
        guard validationMessage == nil else { return false }
        if case .loaded(let accounts) = accountsState {
            return !accounts.isEmpty
        }
        return false
    }

    private func parseForSubmit() -> RepayInput? {
        guard canSubmit else { return nil }
        guard let bankAccountId = selectedAccountId else { return nil }
        guard let amount = parseAmount() else { return nil }
        return RepayInput(bankAccountId: bankAccountId, amount: amount)
    }

    private func money(_ value: Decimal) -> String {
        MoneyFormatter.shared.string(from: value)
    }
}
