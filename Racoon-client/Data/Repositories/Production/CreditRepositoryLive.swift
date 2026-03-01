//
//  CreditRepositoryLive.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//

import Foundation

public final class CreditRepositoryLive: CreditRepository {
    private let client: HTTPClient
    public init(client: HTTPClient) { self.client = client }

    public func getMyCredits() async throws -> [CreditDto] {
        try await client.send(CreditRouter.getMyCredits, as: [CreditDto].self)
    }

    public func take(bankAccountId: String, tariffId: Int64, amount: Double, durationMonths: Int) async throws -> CreditDto {
        try await client.send(
            CreditRouter.take(
                bankAccountId: bankAccountId,
                tariffId: tariffId,
                amount: amount,
                durationMonths: durationMonths
            ),
            as: CreditDto.self
        )
    }

    public func repay(creditId: Int64, bankAccountId: String, amount: Double) async throws -> CreditPaymentDto {
        try await client.send(
            CreditRouter.repay(
                creditId: creditId,
                bankAccountId: bankAccountId,
                amount: amount
            ),
            as: CreditPaymentDto.self
        )
    }

    public func get(creditId: Int64) async throws -> CreditDto {
        try await client.send(CreditRouter.get(creditId: creditId), as: CreditDto.self)
    }

    public func payments(creditId: Int64) async throws -> [CreditPaymentDto] {
        try await client.send(CreditRouter.payments(creditId: creditId), as: [CreditPaymentDto].self)
    }

    public func statistics(creditId: Int64) async throws -> CreditStatisticsDto {
        try await client.send(CreditRouter.statistics(creditId: creditId), as: CreditStatisticsDto.self)
    }

    public func schedule(creditId: Int64) async throws -> [PaymentScheduleDto] {
        try await client.send(CreditRouter.schedule(creditId: creditId), as: [PaymentScheduleDto].self)
    }

    public func tariffs() async throws -> [CreditTariffDto] {
        try await client.send(CreditRouter.tariffs, as: [CreditTariffDto].self)
    }

    public func tariff(id: Int64) async throws -> CreditTariffDto {
        try await client.send(CreditRouter.tariff(id: id), as: CreditTariffDto.self)
    }
}
