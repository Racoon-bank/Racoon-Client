//
//  CreditDetailsViewModel.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import Combine
import Foundation


@MainActor
final class CreditDetailsViewModel: ObservableObject {
    @Published private(set) var state: AsyncViewState = .idle

    @Published private(set) var credit: Credit?
    @Published private(set) var payments: [CreditPayment] = []
    @Published private(set) var statistics: CreditStatistics?
    @Published private(set) var schedule: [PaymentScheduleItem] = []

    @Published private(set) var accountsState: Loadable<[BankAccount]> = .idle

    private let creditId: Int64
    private let getCredit: GetCreditUseCase
    private let repay: RepayCreditUseCase
    private let getPayments: GetCreditPaymentsUseCase
    private let getStatistics: GetCreditStatisticsUseCase
    private let getSchedule: GetCreditScheduleUseCase
    private let getAccounts: GetMyAccountsUseCase

    init(
        creditId: Int64,
        getCredit: GetCreditUseCase,
        repay: RepayCreditUseCase,
        getPayments: GetCreditPaymentsUseCase,
        getStatistics: GetCreditStatisticsUseCase,
        getSchedule: GetCreditScheduleUseCase,
        getAccounts: GetMyAccountsUseCase
    ) {
        self.creditId = creditId
        self.getCredit = getCredit
        self.repay = repay
        self.getPayments = getPayments
        self.getStatistics = getStatistics
        self.getSchedule = getSchedule
        self.getAccounts = getAccounts
    }

    func load() async {
        state = .loading
        do {
            async let creditBlock: Void = reloadCreditBlock()
            async let accountsBlock: Void = loadAccountsIfNeeded()

            _ = try await (creditBlock, accountsBlock)
            state = .idle
        } catch {
            state = .error(message: "Failed to load credit.")
        }
    }

    func refresh() async {
        do {
            async let creditBlock: () = reloadCreditBlock()
            async let accountsBlock: () = loadAccountsIfNeeded()
            _ = try await (creditBlock, accountsBlock)
        } catch {
            state = .error(message: "Failed to refresh.")
        }
    }

    func repayCredit(bankAccountId: UUID, amount: Decimal) async {
        state = .loading
        do {
            _ = try await repay(creditId: creditId, bankAccountId: bankAccountId, amount: amount)
            try await reloadCreditBlock()
            state = .idle
        } catch {
            state = .error(message: mapRepayError(error))
        }
    }
    private func mapRepayError(_ error: Error) -> String {
        if let e = error as? NetworkError {
            switch e {
            case .httpStatus(let code, _):
                switch code {
                case 400: return "Invalid payment amount."
                case 401: return "Session expired. Please sign in again."
                case 403: return "You don’t have permission to do this."
                case 404: return "Credit or account not found."
                case 409: return "Insufficient funds in the selected account."
                default:  return "Payment failed (code \(code)). Please try again."
                }
            default:
                break
            }
        }

        return "Payment failed. Please try again."
    }

    func clearError() {
        if case .error = state { state = .idle }
    }

    func retryAccounts() async {
        _ = try? await forceReloadAccounts()
    }

    // MARK: - Internals

    private func reloadCreditBlock() async throws {
        async let c = getCredit(creditId: creditId)
        async let p = getPayments(creditId: creditId)
        async let s = getStatistics(creditId: creditId)
        async let sch = getSchedule(creditId: creditId)

        let (credit, payments, statistics, schedule) = try await (c, p, s, sch)
        self.credit = credit
        self.payments = payments
        self.statistics = statistics
        self.schedule = schedule
    }

    private func loadAccountsIfNeeded() async throws {
        if case .loaded = accountsState { return }
        try await forceReloadAccounts()
    }

    @discardableResult
    private func forceReloadAccounts() async throws -> [BankAccount] {
        accountsState = .loading
        do {
            let accounts = try await getAccounts()
            accountsState = .loaded(accounts)
            return accounts
        } catch {
            accountsState = .failed(message: "Failed to load accounts.")
            throw error
        }
    }
}
