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
    @Published var selectedCurrency: Currency = .RUB

    private let getMyAccounts: GetMyAccountsUseCase
    private let openAccount: OpenAccountUseCase
    private let appErrorBus: AppErrorBus
    private let appErrorMapper: AppErrorMapper

    init(
        getMyAccounts: GetMyAccountsUseCase,
        openAccount: OpenAccountUseCase,
        appErrorBus: AppErrorBus,
        appErrorMapper: AppErrorMapper
    ) {
        self.getMyAccounts = getMyAccounts
        self.openAccount = openAccount
        self.appErrorBus = appErrorBus
        self.appErrorMapper = appErrorMapper
    }

    // MARK: - Load

    func load() async {
        state = .loading

        do {
            accounts = try await getMyAccounts()
            state = .idle
        } catch let error as NetworkError {
            await handleNetworkError(
                error,
                localMessage: "Failed to load accounts."
            )
        } catch {
            state = .error(message: "Failed to load accounts.")
        }
    }

    // MARK: - Refresh

    func refresh() async {
        do {
            accounts = try await getMyAccounts()
        } catch let error as NetworkError {
            await handleNetworkError(
                error,
                localMessage: "Failed to refresh accounts."
            )
        } catch {
            state = .error(message: "Failed to refresh accounts.")
        }
    }

    // MARK: - Create

    func createAccount() async {
        state = .loading

        do {
            let new = try await openAccount(currency: selectedCurrency)
            accounts.insert(new, at: 0)
            state = .idle
        } catch let error as NetworkError {
            await handleNetworkError(
                error,
                localMessage: "Failed to open a new account."
            )
        } catch {
            state = .error(message: "Failed to open a new account.")
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
