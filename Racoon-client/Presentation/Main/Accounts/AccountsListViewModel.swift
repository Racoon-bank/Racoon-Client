//
//  AccountsListViewModel.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import Combine
import SwiftUI

@MainActor
final class AccountsListViewModel: ObservableObject {
    @Published private(set) var state: AsyncViewState = .idle
    @Published private(set) var accounts: [BankAccount] = []
    @Published var selectedCurrency: Currency = .RUB

    private let getMyAccounts: GetMyAccountsUseCase
    private let openAccount: OpenAccountUseCase
    
    private let connectBankHub: ConnectBankHubUseCase
    private let disconnectBankHub: DisconnectBankHubUseCase
    private let subscribeToAccount: SubscribeToAccountUseCase
    
    private let eventBus: DomainEventBus
    private let appErrorBus: AppErrorBus
    private let appErrorMapper: AppErrorMapper

    init(
        getMyAccounts: GetMyAccountsUseCase,
        openAccount: OpenAccountUseCase,
        connectBankHub: ConnectBankHubUseCase,
        disconnectBankHub: DisconnectBankHubUseCase,
        subscribeToAccount: SubscribeToAccountUseCase,
        eventBus: DomainEventBus,
        appErrorBus: AppErrorBus,
        appErrorMapper: AppErrorMapper
    ) {
        self.getMyAccounts = getMyAccounts
        self.openAccount = openAccount
        self.connectBankHub = connectBankHub
        self.disconnectBankHub = disconnectBankHub
        self.subscribeToAccount = subscribeToAccount
        self.eventBus = eventBus
        self.appErrorBus = appErrorBus
        self.appErrorMapper = appErrorMapper
        
        listenForUpdates()
    }

    // MARK: - Load

    func load() async {
        state = .loading

        do {
            accounts = try await getMyAccounts()
            state = .idle
            
            await setupRealTimeUpdates(for: accounts)
        } catch let error as NetworkError {
            await handleNetworkError(error, localMessage: "Failed to load accounts.")
        } catch {
            state = .error(message: "Failed to load accounts.")
        }
    }

    // MARK: - Refresh

    func refresh() async {
        do {
            accounts = try await getMyAccounts()
            await setupRealTimeUpdates(for: accounts)
        } catch let error as NetworkError {
            await handleNetworkError(error, localMessage: "Failed to refresh accounts.")
        } catch {
            state = .error(message: "Failed to refresh accounts.")
        }
    }
    
    // MARK: - Event Bus Listener
    
    private func listenForUpdates() {
         Task {
             for await event in eventBus.events {
                 if case .accountUpdated(let updatedAccountId) = event {
                     
                     if self.accounts.contains(where: { $0.id == updatedAccountId }) {
                         print("🔄 AccountsList: Refreshing balances due to WS ping for \(updatedAccountId)!")
                     
                         do {
                             let updatedAccounts = try await self.getMyAccounts()
                             withAnimation {
                                 self.accounts = updatedAccounts
                             }
                         } catch {
                             print("⚠️ Failed to silently refresh accounts: \(error)")
                         }
                     }
                 }
             }
         }
     }

    // MARK: - Create

    func createAccount() async {
        state = .loading

        do {
            let new = try await openAccount(currency: selectedCurrency)
            withAnimation {
                accounts.insert(new, at: 0)
            }
            
            try? await subscribeToAccount(accountId: new.id)
            
            state = .idle
        } catch let error as NetworkError {
            await handleNetworkError(error, localMessage: "Failed to open a new account.")
        } catch {
            state = .error(message: "Failed to open a new account.")
        }
    }

    // MARK: - WebSockets Helper
    
    private func setupRealTimeUpdates(for accounts: [BankAccount]) async {
        await connectBankHub()
        
        for account in accounts {
            do {
                try await subscribeToAccount(accountId: account.id)
                print("✅ Subscribed to updates for account: \(account.id)")
            } catch {
                print("⚠️ Failed to subscribe to account \(account.id): \(error)")
            }
        }
    }

    // MARK: - Error Handling

    private func handleNetworkError(_ error: NetworkError, localMessage: String) async {
        if let global = appErrorMapper.mapNetworkToGlobal(error) {
            state = .idle
             appErrorBus.post(global)
        } else {
            state = .error(message: localMessage)
        }
    }

    func clearError() {
        if case .error = state {
            state = .idle
        }
    }
}
