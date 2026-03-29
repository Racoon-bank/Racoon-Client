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
    private let transfer: TransferUseCase
    private let closeAccount: CloseAccountUseCase
    private let getHistory: GetAccountHistoryUseCase
    private let toggleHiddenAccount: ToggleHiddenAccountUseCase
    
    private let connectBankHub: ConnectBankHubUseCase
    private let subscribeToAccount: SubscribeToAccountUseCase
    private let eventBus: DomainEventBus

    init(
        accountId: UUID,
        getMyAccounts: GetMyAccountsUseCase,
        deposit: DepositUseCase,
        withdraw: WithdrawUseCase,
        transfer: TransferUseCase,
        closeAccount: CloseAccountUseCase,
        getHistory: GetAccountHistoryUseCase,
        toggleHiddenAccount: ToggleHiddenAccountUseCase,
        connectBankHub: ConnectBankHubUseCase,
        subscribeToAccount: SubscribeToAccountUseCase,
        eventBus: DomainEventBus
    ) {
        self.accountId = accountId
        self.getMyAccounts = getMyAccounts
        self.deposit = deposit
        self.withdraw = withdraw
        self.transfer = transfer
        self.closeAccount = closeAccount
        self.getHistory = getHistory
        self.toggleHiddenAccount = toggleHiddenAccount
        self.connectBankHub = connectBankHub
        self.subscribeToAccount = subscribeToAccount
        self.eventBus = eventBus
    }


    func observeEvents() async {
        print("🎧 Detail View: Listening for events for \(accountId)")
        for await event in eventBus.events {
            if case .accountUpdated(let updatedAccountId) = event, updatedAccountId == accountId {
                print("🔄 Detail View: Refreshing history & balance due to WS ping!")
                do {
                    try await reloadAccountAndHistory()
                } catch {
                    print("❌ Detail View: Failed to refresh on ping: \(error)")
                }
            } else if case .visibilityChanged(let changedAccountId) = event, changedAccountId == accountId {
                do { try await reloadAccountAndHistory() } catch { }
            }
        }
    }

    func load() async {
        guard account == nil else { return }
        
        state = .loading
        do {
            try await reloadAccountAndHistory()
            state = .idle
            
            try? await subscribeToAccount(accountId: accountId)
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
            _ = try await deposit(accountId: accountId, amount: amount)
            try await reloadAccountAndHistory()
            state = .idle
        } catch {
            state = .error(message: "Deposit failed.")
        }
    }

    func makeWithdraw(amount: Decimal) async {
        state = .loading
        do {
            _ = try await withdraw(accountId: accountId, amount: amount)
            try await reloadAccountAndHistory()
            state = .idle
        } catch {
            state = .error(message: "Withdraw failed.")
        }
    }
    
    func makeTransfer(to targetAccountNumber: String, amount: Decimal) async {
           state = .loading
           do {
               try await transfer(fromAccountId: accountId, toAccountNumber: targetAccountNumber, amount: amount)
               try await reloadAccountAndHistory()
               state = .idle
           } catch {
               state = .error(message: "Transfer failed.")
           }
       }

    func toggleVisibility() async {
        guard let account = account else { return }
        state = .loading
        do {
            try await toggleHiddenAccount(accountId: account.id)
            try await reloadAccountAndHistory()
            state = .idle
        } catch {
            state = .error(message: "Failed to change visibility.")
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
