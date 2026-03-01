//
//  CreditStatisticsMapper.swift
//  Racoon-client
//
//  Created by dark type on 01.03.2026.
//


import Foundation

enum CreditStatisticsMapper {
    static func toDomain(_ dto: CreditStatisticsDto) -> CreditStatistics {
        CreditStatistics(
            creditId: dto.creditId,
            originalAmount: Decimal(dto.originalAmount),
            monthlyPayment: Decimal(dto.monthlyPayment),
            durationMonths: dto.durationMonths,
            interestRate: Decimal(dto.interestRate),
            totalToRepay: Decimal(dto.totalToRepay),
            totalInterest: Decimal(dto.totalInterest)
        )
    }
}
