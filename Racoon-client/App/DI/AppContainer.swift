//
//  AppContainer.swift
//  Racoon-client
//
//  Created by dark type on 26.02.2026.
//


import Foundation

public final class AppContainer: @unchecked Sendable {
    public static let shared = AppContainer()

    private let env: NetworkEnvironment
    private let networkingAssembly: NetworkingAssembly
    private let repositoriesAssembly: RepositoriesAssembly

    public let tokenStore: TokenStore
    public let bareHTTP: HTTPClient
    public let authedHTTP: HTTPClient

    public let recentCreditsStore: RecentCreditsStore
    public let eventBus: DomainEventBus
    public let appErrorBus: AppErrorBus
    public let appErrorMapper: AppErrorMapper
    
    public let coreAuthRepository: any CoreAuthRepository
    public let tokenRefresher: any TokenRefresher

    public let coreBankAccountRepository: CoreBankAccountRepository
    public let infoUserRepository: InfoUserRepository
    public let creditRepository: CreditRepository

    public let loginUseCase: LoginUseCase
    public let registerUseCase: RegisterUseCase
    public let logoutUseCase: LogoutUseCase
    public let getProfileUseCase: GetProfileUseCase

    public let openAccountUseCase: OpenAccountUseCase
    public let closeAccountUseCase: CloseAccountUseCase
    public let getMyAccountsUseCase: GetMyAccountsUseCase
    public let depositUseCase: DepositUseCase
    public let withdrawUseCase: WithdrawUseCase
    public let getAccountHistoryUseCase: GetAccountHistoryUseCase
    public let bankHubClient: BankHubClient

    public let getMyCreditsUseCase: GetMyCreditsUseCase
    public let getCreditTariffsUseCase: GetCreditTariffsUseCase
    public let getCreditStatisticsUseCase: GetCreditStatisticsUseCase
    public let getCreditScheduleUseCase: GetCreditScheduleUseCase

    public let takeCreditUseCase: TakeCreditUseCase
    public let repayCreditUseCase: RepayCreditUseCase
    public let getCreditUseCase: GetCreditUseCase
    public let getCreditPaymentsUseCase: GetCreditPaymentsUseCase

    public let appSettingsStorage: AppSettingsStorage
    public let loadAppSettingsUseCase: LoadAppSettingsUseCase
    public let setThemeUseCase: SetThemeUseCase
    public let toggleHiddenAccountUseCase: ToggleHiddenAccountUseCase
    public let syncThemeFromProfileUseCase: SyncThemeFromProfileUseCase
    public let syncHiddenAccountsUseCase: SyncHiddenAccountsUseCase
    
    private init() {
        self.env = NetworkEnvironment.fromBuildConfig()
        self.networkingAssembly = NetworkingAssembly(env: env)
        self.repositoriesAssembly = RepositoriesAssembly(networking: networkingAssembly)

        self.tokenStore = networkingAssembly.makeTokenStore()
        self.recentCreditsStore = UserDefaultsRecentCreditsStore()
        self.eventBus = InMemoryDomainEventBus()
        self.appErrorBus = InMemoryAppErrorBus()
        self.appErrorMapper = AppErrorMapper()
        

        self.bareHTTP = networkingAssembly.makeBareHTTPClient()

            let authLive = repositoriesAssembly.makeCoreAuthRepository(
                bareClient: bareHTTP,
                tokenStore: tokenStore
            )

            self.coreAuthRepository = authLive
            self.tokenRefresher = authLive

        self.authedHTTP = networkingAssembly.makeAuthedHTTPClient(
            tokenStore: tokenStore,
            tokenRefresher: tokenRefresher,
            appErrorBus: appErrorBus
        )

            self.coreBankAccountRepository = repositoriesAssembly.makeCoreBankAccountRepository(authedClient: authedHTTP)
            self.infoUserRepository = repositoriesAssembly.makeInfoUserRepository(authedClient: authedHTTP)
            self.creditRepository = repositoriesAssembly.makeCreditRepository(authedClient: authedHTTP)

        self.bankHubClient = networkingAssembly.makeBankHubClient(tokenStore: tokenStore)

        let useCases = UseCasesAssembly(
            authRepo: coreAuthRepository,
            bankRepo: coreBankAccountRepository,
            infoRepo: infoUserRepository,
            creditRepo: creditRepository,
            events: eventBus,
            tokenStore: tokenStore
        )

        self.loginUseCase = useCases.makeLoginUseCase()
        self.registerUseCase = useCases.makeRegisterUseCase()
        self.logoutUseCase = useCases.makeLogoutUseCase()
        self.getProfileUseCase = useCases.makeGetProfileUseCase()

        self.openAccountUseCase = useCases.makeOpenAccountUseCase()
        self.closeAccountUseCase = useCases.makeCloseAccountUseCase()
        self.getMyAccountsUseCase = useCases.makeGetMyAccountsUseCase()
        self.depositUseCase = useCases.makeDepositUseCase()
        self.withdrawUseCase = useCases.makeWithdrawUseCase()
        self.getAccountHistoryUseCase = useCases.makeGetAccountHistoryUseCase()

        self.getMyCreditsUseCase = useCases.makeGetMyCreditsUseCase()
        self.getCreditTariffsUseCase = useCases.makeGetCreditTariffsUseCase()
        self.getCreditStatisticsUseCase = useCases.makeGetCreditStatisticsUseCase()
        self.getCreditScheduleUseCase = useCases.makeGetCreditScheduleUseCase()

        self.takeCreditUseCase = useCases.makeTakeCreditUseCase()
        self.repayCreditUseCase = useCases.makeRepayCreditUseCase()
        self.getCreditUseCase = useCases.makeGetCreditUseCase()
        self.getCreditPaymentsUseCase = useCases.makeGetCreditPaymentsUseCase()
        
        self.appSettingsStorage = UserDefaultsAppSettingsStorage()
        self.loadAppSettingsUseCase = LoadAppSettingsUseCaseMock()
        self.setThemeUseCase = SetThemeUseCaseImpl(
            storage: appSettingsStorage,
            events: eventBus
        )
        self.toggleHiddenAccountUseCase = ToggleHiddenAccountUseCaseImpl(
            storage: appSettingsStorage,
            events: eventBus
        )

        self.syncThemeFromProfileUseCase = SyncThemeFromProfileUseCaseImpl(
            getProfile: self.getProfileUseCase,
            storage: appSettingsStorage,
            events: eventBus
        )

        self.syncHiddenAccountsUseCase = SyncHiddenAccountsUseCaseImpl(
            getAccounts: self.getMyAccountsUseCase,
            storage: appSettingsStorage
        )
    }
}
