//
//  ViewModelFactory.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import Foundation

@MainActor
final class ViewModelFactory {
    private let container: AppContainer
    
    init(container: AppContainer) {
        self.container = container
    
    }

    func makeLoginViewModel(appState: AppState) -> LoginViewModel {
        LoginViewModel(completeLogin: container.loginUseCase, appState: appState)
    }

    func makeProfileViewModel(appState: AppState) -> ProfileViewModel {
        ProfileViewModel(
            getProfile: container.getProfileUseCase,
            logout: container.logoutUseCase,
            setTheme: container.setThemeUseCase,
            appSettingsStorage: container.appSettingsStorage, appState: appState
        )
    }


    func makeAccountsListViewModel() -> AccountsListViewModel {
        AccountsListViewModel(
            getMyAccounts: container.getMyAccountsUseCase,
            openAccount: container.openAccountUseCase,
            connectBankHub: container.connectBankHubUseCase,
            disconnectBankHub: container.disconnectBankHubUseCase,
            subscribeToAccount: container.subscribeToAccountUseCase,
            eventBus: container.eventBus,
            appErrorBus: container.appErrorBus,
            appErrorMapper: container.appErrorMapper
            
        )
    }
    
    func makeAccountDetailsViewModel(accountId: UUID) -> AccountDetailsViewModel {
            AccountDetailsViewModel(
                accountId: accountId,
                getMyAccounts: container.getMyAccountsUseCase,
                deposit: container.depositUseCase,
                withdraw: container.withdrawUseCase,
                transfer: container.transferMoneyUseCase,
                closeAccount: container.closeAccountUseCase,
                getHistory: container.getAccountHistoryUseCase,
                toggleHiddenAccount: container.toggleHiddenAccountUseCase,
                connectBankHub: container.connectBankHubUseCase,
                subscribeToAccount: container.subscribeToAccountUseCase,
                eventBus: container.eventBus
            )
        }
    
    func makeCreditsHomeViewModel(appState: AppState) -> CreditsHomeViewModel {
        CreditsHomeViewModel(
            getMyCredits: container.getMyCreditsUseCase,
            getMyRating: container.getMyCreditRatingUseCase,
            getMyApplications: container.getMyCreditApplicationsUseCase, getMyOverduePayments: container.getMyOverduePaymentsUseCase,
            takeCredit:  container.takeCreditUseCase
        )
    }

    func makeTakeCreditSheetViewModel() -> TakeCreditSheetViewModel {
        TakeCreditSheetViewModel(
            getAccounts: container.getMyAccountsUseCase,
            getTariffs: container.getCreditTariffsUseCase
        )
    }

    func makeCreditDetailsViewModel(creditId: Int64) -> CreditDetailsViewModel {
        CreditDetailsViewModel(
            creditId: creditId,
            getCredit: container.getCreditUseCase,
            repay: container.repayCreditUseCase,
            getPayments: container.getCreditPaymentsUseCase,
            getStatistics: container.getCreditStatisticsUseCase,
            getSchedule: container.getCreditScheduleUseCase,
            getAccounts: container.getMyAccountsUseCase
        )
    }
    func makeRegisterViewModel(appState: AppState) -> RegisterViewModel {
        RegisterViewModel(register: container.registerUseCase, appState: appState)
    }
    

}
