//
//  TakeCreditSheetViewModel.swift
//  Racoon-client
//
//  Created by dark type on 01.03.2026.
//


import Combine
import SwiftUI

@MainActor
final class TakeCreditSheetViewModel: ObservableObject {
    @Published private(set) var state: AsyncViewState = .idle
    @Published private(set) var accounts: [BankAccount] = []
    @Published private(set) var tariffs: [CreditTariff] = []

    @Published var selectedAccountId: UUID?
    @Published var selectedTariffId: Int64?

    @Published var amountText: String = ""
    @Published var durationMonthsText: String = ""

    private let getAccounts: GetMyAccountsUseCase
    private let getTariffs: GetCreditTariffsUseCase

    init(getAccounts: GetMyAccountsUseCase, getTariffs: GetCreditTariffsUseCase) {
        self.getAccounts = getAccounts
        self.getTariffs = getTariffs
    }

    func load() async {
        state = .loading
        do {
            async let a = getAccounts()
            async let t = getTariffs()
            let (accounts, tariffs) = try await (a, t)

            self.accounts = accounts
            self.tariffs = tariffs

            if selectedAccountId == nil { selectedAccountId = accounts.first?.id }
            if selectedTariffId == nil { selectedTariffId = tariffs.first?.id }

            state = .idle
        } catch {
            state = .error(message: "Failed to load accounts or tariffs.")
        }
    }

    func parse() -> TakeCreditInput? {
        guard
            let bankAccountId = selectedAccountId,
            let tariffId = selectedTariffId
        else { return nil }

        let normalizedAmount = amountText.replacingOccurrences(of: ",", with: ".")
        guard let amount = Decimal(string: normalizedAmount), amount > 0 else { return nil }

        guard
            let months = Int(durationMonthsText.trimmingCharacters(in: .whitespacesAndNewlines)),
            months > 0
        else { return nil }

        return TakeCreditInput(bankAccountId: bankAccountId, tariffId: tariffId, amount: amount, durationMonths: months)
    }

    func clearError() {
        if case .error = state { state = .idle }
    }
}
