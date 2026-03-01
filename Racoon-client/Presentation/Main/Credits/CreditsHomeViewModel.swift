//
//  CreditsHomeViewModel.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//

import Combine
import Foundation

@MainActor
final class CreditsHomeViewModel: ObservableObject {
    @Published private(set) var state: AsyncViewState = .idle

    @Published private(set) var myCredits: [Credit] = []
    @Published private(set) var recentCreditIds: [Int64] = []
    @Published var openCreditIdText: String = ""

    private let getMyCredits: GetMyCreditsUseCase
    private let takeCredit: TakeCreditUseCase
    private let recentStore: RecentCreditsStore
    private unowned let appState: AppState

    init(
        getMyCredits: GetMyCreditsUseCase,
        takeCredit: TakeCreditUseCase,
        recentStore: RecentCreditsStore,
        appState: AppState
    ) {
        self.getMyCredits = getMyCredits
        self.takeCredit = takeCredit
        self.recentStore = recentStore
        self.appState = appState
    }

    func load() async {
        state = .loading
        do {
            async let creditsTask = getMyCredits()
            async let recentsTask = recentStore.load()
            let (credits, recents) = try await (creditsTask, recentsTask)

            myCredits = credits
            recentCreditIds = recents
            state = .idle
        } catch {
            state = .error(message: "Failed to load credits.")
        }
    }

    func refresh() async {
        do {
            myCredits = try await getMyCredits()
        } catch {
            state = .error(message: "Failed to refresh credits.")
        }
    }

    func createCredit(bankAccountId: UUID, tariffId: Int64, amount: Decimal, durationMonths: Int) async -> Int64? {
        state = .loading
        defer { if case .loading = state { state = .idle } }

        do {
            let credit = try await takeCredit(
                bankAccountId: bankAccountId,
                tariffId: tariffId,
                amount: amount,
                durationMonths: durationMonths
            )

            appState.lastCreatedCreditId = credit.id
            await recentStore.add(credit.id)
            recentCreditIds = await recentStore.load()

            myCredits = try await getMyCredits()

            return credit.id
        } catch {
            state = .error(message: "Failed to take a credit.")
            return nil
        }
    }

    func openCreditIdFromText() -> Int64? {
        Int64(openCreditIdText.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    func markOpened(_ id: Int64) async {
        appState.lastCreatedCreditId = id
        await recentStore.add(id)
        recentCreditIds = await recentStore.load()
    }

    func removeRecent(_ id: Int64) async {
        await recentStore.remove(id)
        recentCreditIds = await recentStore.load()
    }

    func clearRecents() async {
        await recentStore.clear()
        recentCreditIds = await recentStore.load()
    }

    func clearError() {
        if case .error = state { state = .idle }
    }
}
