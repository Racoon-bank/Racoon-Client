//
//  CreditTariffMapper.swift
//  Racoon-client
//
//  Created by dark type on 01.03.2026.
//


import Foundation

enum CreditTariffMapper {
    static func toDomain(_ dto: CreditTariffDto) -> CreditTariff {
        CreditTariff(
            id: dto.id,
            name: dto.name,
            interestRate: Decimal(dto.interestRate),
            dueDate: dto.dueDate,
            isActive: dto.isActive,
            createdAt: dto.createdAt
        )
    }
}
