//
//  PaymentScheduleMapper.swift
//  Racoon-client
//
//  Created by dark type on 01.03.2026.
//


import Foundation

enum PaymentScheduleMapper {
    static func toDomain(_ dto: PaymentScheduleDto) -> PaymentScheduleItem {
        PaymentScheduleItem(
            id: dto.id,
            creditId: dto.creditId,
            monthNumber: dto.monthNumber,
            paymentDate: dto.paymentDate,
            totalPayment: Decimal(dto.totalPayment),
            interestPayment: Decimal(dto.interestPayment),
            principalPayment: Decimal(dto.principalPayment),
            remainingBalance: Decimal(dto.remainingBalance),
            paid: dto.paid
        )
    }
}
