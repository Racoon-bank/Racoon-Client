//
//  AccountsListViewModel.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import Combine

@MainActor
final class AccountsListViewModel: ObservableObject {
    @Published private(set) var state: AsyncViewState = .idle
    @Published private(set) var accounts: [BankAccount] = []

    private let getMyAccounts: GetMyAccountsUseCase
    private let openAccount: OpenAccountUseCase

    init(getMyAccounts: GetMyAccountsUseCase, openAccount: OpenAccountUseCase) {
        self.getMyAccounts = getMyAccounts
        self.openAccount = openAccount
    }

    func load() async {
        state = .loading
        do {
            accounts = try await getMyAccounts()
            state = .idle
        } catch {
            state = .error(message: "Failed to load accounts.")
        }
    }

    func refresh() async {
        do {
            accounts = try await getMyAccounts()
        } catch {
            state = .error(message: "Failed to refresh accounts.")
        }
    }

    func createAccount() async {
        state = .loading
        do {
            let new = try await openAccount()
            accounts.insert(new, at: 0)
            state = .idle
        } catch {
            state = .error(message: "Failed to open a new account.")
        }
    }

    func clearError() {
        if case .error = state { state = .idle }
    }
}
