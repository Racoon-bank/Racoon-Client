//
//  CreditRepository.swift
//  Racoon-client
//
//  Created by dark type on 26.02.2026.
//

import Foundation

public protocol CreditRepository: Sendable {
    func getMyCredits() async throws -> [CreditDto]

    func take(bankAccountId: String, tariffId: Int64, amount: Double, durationMonths: Int) async throws -> CreditDto
    func repay(creditId: Int64, bankAccountId: String, amount: Double) async throws -> CreditPaymentDto

    func get(creditId: Int64) async throws -> CreditDto
    func payments(creditId: Int64) async throws -> [CreditPaymentDto]

    func statistics(creditId: Int64) async throws -> CreditStatisticsDto
    func schedule(creditId: Int64) async throws -> [PaymentScheduleDto]

    func tariffs() async throws -> [CreditTariffDto]
    func tariff(id: Int64) async throws -> CreditTariffDto
}
