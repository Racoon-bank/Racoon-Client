//
//  UseCasesAssembly.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import Foundation

public struct UseCasesAssembly: Sendable {
    private let authRepo: CoreAuthRepository
    private let bankRepo: CoreBankAccountRepository
    private let infoRepo: InfoUserRepository
    private let creditRepo: CreditRepository
    private let events: DomainEventBus
    private let tokenStore: TokenStore

    public init(
        authRepo: CoreAuthRepository,
        bankRepo: CoreBankAccountRepository,
        infoRepo: InfoUserRepository,
        creditRepo: CreditRepository,
        events: DomainEventBus,
        tokenStore: TokenStore
    ) {
        self.authRepo = authRepo
        self.bankRepo = bankRepo
        self.infoRepo = infoRepo
        self.creditRepo = creditRepo
        self.tokenStore = tokenStore
        self.events = events
    }

    public func makeLoginUseCase() -> LoginUseCase {
        LoginUseCaseImpl(authRepo: authRepo, events: events)
    }

    public func makeRegisterUseCase() -> RegisterUseCase {
        RegisterUseCaseImpl(authRepo: authRepo, events: events)
    }
    public func makeLogoutUseCase() -> LogoutUseCase {
        LogoutUseCaseImpl(authRepo: authRepo, tokenStore: tokenStore, events: events)
    }

    public func makeGetProfileUseCase() -> GetProfileUseCase {
        GetProfileUseCaseImpl(infoRepo: infoRepo)
    }

    public func makeOpenAccountUseCase() -> OpenAccountUseCase {
        OpenAccountUseCaseImpl(repo: bankRepo)
    }

    public func makeCloseAccountUseCase() -> CloseAccountUseCase {
        CloseAccountUseCaseImpl(repo: bankRepo)
    }

    public func makeGetMyAccountsUseCase() -> GetMyAccountsUseCase {
        GetMyAccountsUseCaseImpl(repo: bankRepo)
    }

    public func makeDepositUseCase() -> DepositUseCase {
        DepositUseCaseImpl(repo: bankRepo, events: events)
    }

    public func makeWithdrawUseCase() -> WithdrawUseCase {
        WithdrawUseCaseImpl(repo: bankRepo, events: events)
    }

    public func makeGetAccountHistoryUseCase() -> GetAccountHistoryUseCase {
        GetAccountHistoryUseCaseImpl(repo: bankRepo)
    }

    public func makeGetMyCreditsUseCase() -> GetMyCreditsUseCase {
           GetMyCreditsUseCaseImpl(creditRepo: creditRepo)
       }

    public func makeTakeCreditUseCase() -> TakeCreditUseCase {
           TakeCreditUseCaseImpl(creditRepo: creditRepo, events: events)
       }
    public func makeRepayCreditUseCase() -> RepayCreditUseCase {
        RepayCreditUseCaseImpl(creditRepo: creditRepo, events: events)
    }

    public func makeGetCreditUseCase() -> GetCreditUseCase {
        GetCreditUseCaseImpl(creditRepo: creditRepo)
    }

    public func makeGetCreditPaymentsUseCase() -> GetCreditPaymentsUseCase {
        GetCreditPaymentsUseCaseImpl(creditRepo: creditRepo)
    }

    public func makeGetCreditTariffsUseCase() -> GetCreditTariffsUseCase {
        GetCreditTariffsUseCaseImpl(creditRepo: creditRepo)
    }

    public func makeGetCreditStatisticsUseCase() -> GetCreditStatisticsUseCase {
        GetCreditStatisticsUseCaseImpl(creditRepo: creditRepo)
    }

    public func makeGetCreditScheduleUseCase() -> GetCreditScheduleUseCase {
        GetCreditScheduleUseCaseImpl(creditRepo: creditRepo)
    }
}
