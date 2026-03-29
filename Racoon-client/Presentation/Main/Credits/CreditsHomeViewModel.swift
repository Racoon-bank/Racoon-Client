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

    @Published  var rating: CreditRating?
    @Published  var applications: [CreditApplication] = []
    @Published var overduePayments: [OverduePayment] = []
    @Published  var myCredits: [Credit] = []

    private let getMyCredits: GetMyCreditsUseCase
    private let getMyRating: GetMyCreditRatingUseCase
    private let getMyApplications: GetMyCreditApplicationsUseCase
    private let getMyOverduePayments: GetMyOverduePaymentsUseCase
    private let takeCredit: TakeCreditUseCase

    init(
        getMyCredits: GetMyCreditsUseCase,
        getMyRating: GetMyCreditRatingUseCase,
        getMyApplications: GetMyCreditApplicationsUseCase,
        getMyOverduePayments: GetMyOverduePaymentsUseCase,
        takeCredit: TakeCreditUseCase
    ) {
        self.getMyCredits = getMyCredits
        self.getMyRating = getMyRating
        self.getMyApplications = getMyApplications
        self.getMyOverduePayments = getMyOverduePayments
        self.takeCredit = takeCredit
    }

    func load() async {
        state = .loading
        do {
            async let creditsTask = getMyCredits()
            async let ratingTask = getMyRating()
            async let appsTask = getMyApplications()
            async let overdueTask = getMyOverduePayments()

            let (credits, rating, apps, overdues) = try await (creditsTask, ratingTask, appsTask, overdueTask)

            self.myCredits = credits
            self.rating = rating
            self.applications = apps
            self.overduePayments = overdues
            
            state = .idle
        } catch {
            state = .error(message: "Failed to load credit data.")
        }
    }

    func refresh() async {
        await load()
    }

    func createCredit(bankAccountId: UUID, tariffId: Int64, amount: Decimal, durationMonths: Int) async {
        state = .loading
        do {
            _ = try await takeCredit(
                bankAccountId: bankAccountId,
                tariffId: tariffId,
                amount: amount,
                durationMonths: durationMonths
            )
            await load()
        } catch {
            state = .error(message: "Failed to apply for a credit.")
        }
    }

    func clearError() {
        if case .error = state { state = .idle }
    }
}
