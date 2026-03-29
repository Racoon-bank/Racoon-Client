//
//  TakeCreditSheet.swift
//  Racoon-client
//
//  Created by dark type on 01.03.2026.
//


import SwiftUI


struct TakeCreditSheet: View {
    @StateObject private var viewModel: TakeCreditSheetViewModel
    let onConfirm: (TakeCreditInput) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var errorText: String?

    init(viewModel: TakeCreditSheetViewModel, onConfirm: @escaping (TakeCreditInput) -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onConfirm = onConfirm
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Currency") {
                    Picker("Currency", selection: $viewModel.selectedCurrency) {
                        Text("RUB").tag(Currency.RUB)
                        Text("USD").tag(Currency.USD)
                        Text("EUR").tag(Currency.EUR)
                    }
                    .pickerStyle(.segmented)
                }

                Section("Bank account") {
                    if viewModel.accounts.isEmpty {
                        Text("No accounts available.")
                            .foregroundStyle(.secondary)
                    } else {
                        Picker("Account", selection: $viewModel.selectedAccountId) {
                            ForEach(viewModel.accounts) { a in
                                Text("\(a.accountNumber) • \(money(a.balance)) \(a.currency.symbol)")
                                    .tag(Optional(a.id))
                            }
                        }
                    }
                }

                Section("Tariff") {
                    if viewModel.tariffs.isEmpty {
                        Text("No tariffs available.")
                            .foregroundStyle(.secondary)
                    } else {
                        Picker("Tariff", selection: $viewModel.selectedTariffId) {
                            ForEach(viewModel.tariffs) { t in
                                Text("\(t.name) • \(percent(t.interestRate*100))")
                                    .tag(Optional(t.id))
                            }
                        }
                    }
                }

                Section("Amount") {
                    TextField("Amount", text: $viewModel.amountText)
                        .keyboardType(.decimalPad)
                }

                Section("Duration") {
                    TextField("Duration (months)", text: $viewModel.durationMonthsText)
                        .keyboardType(.numberPad)
                }

                if let errorText {
                    Section { Text(errorText).foregroundStyle(.red) }
                }
            }
            .navigationTitle("Apply for Credit")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Apply") {
                        guard let input = viewModel.parse() else {
                            errorText = "Please fill all fields correctly."
                            return
                        }
                        onConfirm(input)
                        dismiss()
                    }
                    .disabled(viewModel.state.isLoading)
                }
            }
            .overlay {
                if viewModel.state.isLoading {
                    ProgressView()
                }
            }
            .task { await viewModel.load() }
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

    private func money(_ value: Decimal) -> String {
        NSDecimalNumber(decimal: value).stringValue
    }

    private func percent(_ value: Decimal) -> String {
        "\(NSDecimalNumber(decimal: value).stringValue)%"
    }
}
