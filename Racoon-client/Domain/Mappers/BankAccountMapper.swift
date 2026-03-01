//
//  BankAccountMapper.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//

import Foundation

enum BankAccountMapper {

    static func toDomain(_ dto: BankAccountDto) -> BankAccount {
        BankAccount(
            id: dto.id,
            userId: dto.userId,
            accountNumber: dto.accountNumber,
            balance: Decimal(dto.balance),
            createdAt: dto.createdAt
        )
    }

    static func toDomain(_ dto: BankAccountOperationDto) -> BankOperation {
        let type: BankOperationType

        switch dto.type {
        case .deposit:
            type = .deposit

        case .withdraw:
            type = .withdraw

        case .creditIssued:
            type = .creditIssued

        case .creditPayment:
            type = .creditPayment

        case .unknown(let raw):
            type = .unknown(raw)
        }

        return BankOperation(
            id: dto.id,
            amount: Decimal(dto.amount),
            type: type,
            createdAt: dto.createdAt
        )
    }
}
