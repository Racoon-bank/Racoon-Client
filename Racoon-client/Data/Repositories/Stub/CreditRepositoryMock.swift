//
//  CreditRepositoryMock.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import Foundation

public final class CreditRepositoryMock: CreditRepository {
    public func getMyCreditRating() async throws -> CreditRatingDto {
        return CreditRatingDto(score: 1, ratingLevel: "LOW")
    }
    
    public func getMyApplications() async throws -> [CreditApplicationDto] {
        return [CreditApplicationDto(
            id: 2,
            tariffName: "ALL",
            amount: 10,
            status: "PAID"
        )]
    }
    
    public func getMyOverduePayments() async throws -> [OverduePaymentDto] {
        return []
    }
    
    public func take(bankAccountId: String, tariffId: Int64, amount: Double, durationMonths: Int) async throws -> TakeCreditResultDto {
        return TakeCreditResultDto(
            resultType: "PAID",
            message: "NO",
            credit: try await getMyCredits().first!,
            application: CreditApplicationDto(
                id: 2,
                tariffName: "ALL",
                amount: 10,
                status: "PAID"
            )
        )

    }
    
    private let db: MockDatabase

    public init(db: MockDatabase = .shared) {
        self.db = db
    }

    public func getMyCredits() async throws -> [CreditDto] {
        await db.getMyCredits()
    }

    public func take(bankAccountId: String, tariffId: Int64, amount: Double, durationMonths: Int) async throws -> CreditDto {
        try await db.takeCredit(
            bankAccountId: bankAccountId,
            tariffId: tariffId,
            amount: amount,
            durationMonths: durationMonths
        )
    }

    public func repay(creditId: Int64, bankAccountId: String, amount: Double) async throws -> CreditPaymentDto {
        try await db.repayCredit(
            creditId: creditId,
            bankAccountId: bankAccountId,
            amount: amount
        )
    }

    public func get(creditId: Int64) async throws -> CreditDto {
        try await db.getCredit(id: creditId)
    }

    public func payments(creditId: Int64) async throws -> [CreditPaymentDto] {
        try await db.getPayments(creditId: creditId)
    }

    public func statistics(creditId: Int64) async throws -> CreditStatisticsDto {
        try await db.getStatistics(creditId: creditId)
    }

    public func schedule(creditId: Int64) async throws -> [PaymentScheduleDto] {
        try await db.getSchedule(creditId: creditId)
    }

    public func tariffs() async throws -> [CreditTariffDto] {
        await db.getTariffs()
    }

    public func tariff(id: Int64) async throws -> CreditTariffDto {
        try await db.getTariff(id: id)
    }
}
