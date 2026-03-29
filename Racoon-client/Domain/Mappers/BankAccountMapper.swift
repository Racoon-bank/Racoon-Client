//
//  BankAccountMapper.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//

import Foundation

enum BankAccountMapper {
    
    static func toDomain(_ dto: BankAccountDto, hiddenAccountIds: Set<UUID>) -> BankAccount {
        BankAccount(
            id: dto.id,
            userId: dto.userId,
            accountNumber: dto.accountNumber,
            balance: Decimal(dto.balance),
            createdAt: dto.createdAt,
            isHidden: hiddenAccountIds.contains(dto.id),
            currency: Currency(dtoValue: dto.currency)
        )
    }

    static func toDomain(_ dto: BankAccountOperationDto) -> BankOperation {
        let type: BankOperationType

        switch dto.type {
        case .deposit: type = .deposit
        case .withdraw: type = .withdraw
        case .creditIssued: type = .creditIssued
        case .creditPayment: type = .creditPayment
        case .unknown(let raw): type = .unknown(raw)
        }

        return BankOperation(
            id: dto.id,
            amount: Decimal(dto.amount),
            type: type,
            createdAt: dto.createdAt
        )
    }
}
