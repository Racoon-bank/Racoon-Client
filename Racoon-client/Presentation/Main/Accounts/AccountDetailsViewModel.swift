//
//  AccountDetailsViewModel.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import Combine
import Foundation

@MainActor
final class AccountDetailsViewModel: ObservableObject {
    @Published private(set) var state: AsyncViewState = .idle
    @Published private(set) var account: BankAccount?
    @Published private(set) var history: [BankOperation] = []

    private let accountId: UUID

    private let getMyAccounts: GetMyAccountsUseCase
    private let deposit: DepositUseCase
    private let withdraw: WithdrawUseCase
    private let closeAccount: CloseAccountUseCase
    private let getHistory: GetAccountHistoryUseCase

    init(
        accountId: UUID,
        getMyAccounts: GetMyAccountsUseCase,
        deposit: DepositUseCase,
        withdraw: WithdrawUseCase,
        closeAccount: CloseAccountUseCase,
        getHistory: GetAccountHistoryUseCase
    ) {
        self.accountId = accountId
        self.getMyAccounts = getMyAccounts
        self.deposit = deposit
        self.withdraw = withdraw
        self.closeAccount = closeAccount
        self.getHistory = getHistory
    }

    func load() async {
        state = .loading
        do {
            try await reloadAccountAndHistory()
            state = .idle
        } catch {
            state = .error(message: "Failed to load account.")
        }
    }

    func refresh() async {
        do {
            try await reloadAccountAndHistory()
        } catch {
            state = .error(message: "Failed to refresh.")
        }
    }

    func makeDeposit(amount: Decimal) async {
        state = .loading
        do {
            let updated = try await deposit(accountId: accountId, amount: amount)
            account = updated
            history = try await getHistory(accountId: accountId)
            state = .idle
        } catch {
            state = .error(message: "Deposit failed.")
        }
    }

    func makeWithdraw(amount: Decimal) async {
        state = .loading
        do {
            let updated = try await withdraw(accountId: accountId, amount: amount)
            account = updated
            history = try await getHistory(accountId: accountId)
            state = .idle
        } catch {
            state = .error(message: "Withdraw failed.")
        }
    }

    func closeThisAccount() async -> Bool {
        state = .loading
        do {
            try await closeAccount(accountId: accountId)
            state = .idle
            return true
        } catch {
            state = .error(message: "Failed to close account.")
            return false
        }
    }

    func clearError() {
        if case .error = state { state = .idle }
    }

    private func reloadAccountAndHistory() async throws {
        let accounts = try await getMyAccounts()
        self.account = accounts.first(where: { $0.id == accountId })
        self.history = try await getHistory(accountId: accountId)
    }
}
