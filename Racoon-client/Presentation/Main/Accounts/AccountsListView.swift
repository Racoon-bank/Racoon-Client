//
//  AccountsListView.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import SwiftUI
import Foundation

struct AccountsListView: View {
    @StateObject private var viewModel: AccountsListViewModel
    @Environment(\.appContainer) private var container

    init(viewModel: AccountsListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        content
            .task { await viewModel.load() }
            .alert("Error", isPresented: Binding(
                get: { viewModel.state.errorMessage != nil },
                set: { newValue in
                    if !newValue { viewModel.clearError() }
                }
            )) {
                Button("OK", role: .cancel) { viewModel.clearError() }
            } message: {
                Text(viewModel.state.errorMessage ?? "")
            }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.state.isLoading && viewModel.accounts.isEmpty {
            ProgressView()
                .navigationTitle("Accounts")
        } else {
            accountsList
        }
    }

    private var accountsList: some View {
        List {
            if viewModel.accounts.isEmpty {
                Section {
                    Text("No accounts yet. Tap “Open account” to create one.")
                        .foregroundStyle(.secondary)
                }
            } else {
                Section {
                    ForEach(viewModel.accounts) { account in
                        NavigationLink {
                            let factory = ViewModelFactory(container: container)
                            AccountDetailsView(
                                viewModel: factory.makeAccountDetailsViewModel(accountId: account.id),
                                accountId: account.id
                            )
                        } label: {
                            AccountRow(account: account)
                        }
                    }
                } header: {
                    Text("Your accounts")
                }
            }
        }
        .navigationTitle("Accounts")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu("Open account") {
                    ForEach([Currency.RUB, .USD, .EUR], id: \.self) { currency in
                        Button(currency.shortDisplay) {
                            viewModel.selectedCurrency = currency
                            Task { await viewModel.createAccount() }
                        }
                    }
                }
                .disabled(viewModel.state.isLoading)
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
}

private struct AccountRow: View {
    let account: BankAccount

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(account.accountNumber ?? "Account \(account.id.uuidString.prefix(8))")
                .font(.headline)

            HStack {
                Text("Balance")
                    .foregroundStyle(.secondary)
                Spacer()
                Text(formatMoney(account.balance, currency: account.currency))
                    .monospacedDigit()
            }
            .font(.subheadline)
        }
        .padding(.vertical, 6)
    }

    private func formatMoney(_ value: Decimal, currency: Currency) -> String {
        let number = NSDecimalNumber(decimal: value)
        return "\(number.stringValue) \(currency.symbol)"
    }
}
