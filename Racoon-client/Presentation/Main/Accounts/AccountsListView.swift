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
            .onAppear {
                Task { await viewModel.load() }
            }
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
            let visibleAccounts = viewModel.accounts
            
            if visibleAccounts.isEmpty {
                Section {
                    Text("No accounts yet. Tap “Open account” to create one.")
                        .foregroundStyle(.secondary)
                }
            } else {
                Section {
                    ForEach(visibleAccounts) { account in
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
            HStack {
                if account.isHidden {
                    Text("•••• •••• ••••")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                } else {
                    Text(account.accountNumber ?? "Unknown Account")
                        .font(.headline)
                    

                    if let number = account.accountNumber {
                        Button {
                            UIPasteboard.general.string = number
                        } label: {
                            Image(systemName: "doc.on.doc")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(4)
                                .background(Color.secondary.opacity(0.1), in: Circle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                Spacer()
                
                if account.isHidden {
                    Image(systemName: "eye.slash")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
            }

            HStack {
                Text("Balance")
                    .foregroundStyle(.secondary)
                Spacer()
                
                if account.isHidden {
                    Text("••••")
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                } else {
                    Text(formatMoney(account.balance, currency: account.currency))
                        .monospacedDigit()
                }
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
