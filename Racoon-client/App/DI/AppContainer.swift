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
    public let appRepository: AppRepository
    
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

    public let loginUseCase: CompleteSSOLoginUseCaseImpl
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
    
    public let connectBankHubUseCase: ConnectBankHubUseCase
    public let disconnectBankHubUseCase: DisconnectBankHubUseCase
    public let subscribeToAccountUseCase: SubscribeToAccountUseCase
    public let unsubscribeFromAccountUseCase: UnsubscribeFromAccountUseCase
    
    public let getMyCreditRatingUseCase: GetMyCreditRatingUseCase
    public let getMyCreditApplicationsUseCase: GetMyCreditApplicationsUseCase
    public let getMyOverduePaymentsUseCase: GetMyOverduePaymentsUseCase
    
    public let transferMoneyUseCase: TransferUseCase
    
    private init() {
        self.env = NetworkEnvironment.fromBuildConfig()
        self.networkingAssembly = NetworkingAssembly(env: env)
        self.repositoriesAssembly = RepositoriesAssembly(networking : networkingAssembly)

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
        self.appSettingsStorage = UserDefaultsAppSettingsStorage()
        self.appRepository = AppRepositoryLive(client: authedHTTP)
        
            self.coreBankAccountRepository = repositoriesAssembly.makeCoreBankAccountRepository(authedClient: authedHTTP)
            self.infoUserRepository = repositoriesAssembly.makeInfoUserRepository(authedClient: authedHTTP)
            self.creditRepository = repositoriesAssembly.makeCreditRepository(authedClient: authedHTTP)

        self.bankHubClient = networkingAssembly.makeBankHubClient(tokenStore: tokenStore, eventBus: eventBus)

        let useCases = UseCasesAssembly(
                   authRepo: coreAuthRepository,
                   bankRepo: coreBankAccountRepository,
                   infoRepo: infoUserRepository,
                   creditRepo: creditRepository,
                   events: eventBus,
                   tokenStore: tokenStore,
                   bankHubClient: bankHubClient,
                   appSettingsStorage: appSettingsStorage
               )

        self.loginUseCase = CompleteSSOLoginUseCaseImpl(
                  tokenStore: self.tokenStore,
                  events: self.eventBus
              )
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
        self.getMyCreditRatingUseCase = useCases.makeGetMyCreditRatingUseCase()
        self.getMyCreditApplicationsUseCase = useCases.makeGetMyCreditApplicationsUseCase()
        self.getMyOverduePaymentsUseCase = useCases.makeGetMyOverduePaymentsUseCase()
       
        self.loadAppSettingsUseCase = LoadAppSettingsUseCaseMock()
        
        self.toggleHiddenAccountUseCase = ToggleHiddenAccountUseCaseImpl(
            storage: appSettingsStorage,
            events: eventBus
        )

        self.setThemeUseCase = SetThemeUseCaseImpl(
            appRepo: self.appRepository,
            storage: appSettingsStorage,
            events: eventBus
        )

        self.syncThemeFromProfileUseCase = SyncThemeFromProfileUseCaseImpl(
            appRepo: self.appRepository,
            storage: appSettingsStorage,
            events: eventBus
        )

        self.syncHiddenAccountsUseCase = SyncHiddenAccountsUseCaseImpl(
            getAccounts: self.getMyAccountsUseCase,
            storage: appSettingsStorage
        )
        self.connectBankHubUseCase = useCases.makeConnectBankHubUseCase()
        self.disconnectBankHubUseCase = useCases.makeDisconnectBankHubUseCase()
        self.subscribeToAccountUseCase = useCases.makeSubscribeToAccountUseCase()
        self.unsubscribeFromAccountUseCase = useCases.makeUnsubscribeFromAccountUseCase()
        
        self.transferMoneyUseCase = useCases.makeTransferMoneyUseCase()
    }
}
