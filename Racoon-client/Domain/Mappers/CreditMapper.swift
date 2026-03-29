//
//  CreditMapper.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import Foundation

enum CreditMapper {
    static func toDomain(_ dto: CreditDto) -> Credit {
        Credit(
            id: dto.id,
            ownerId: UUID(uuidString: dto.ownerId) ?? UUID(),

            tariffId: dto.tariffId,
            tariffName: dto.tariffName,

            interestRate: Decimal(dto.interestRate),

            currency: dto.currency, amount: Decimal(dto.amount),
            remainingAmount: Decimal(dto.remainingAmount),
            monthlyPayment: Decimal(dto.monthlyPayment),
            
            totalAmount: dto.totalAmount, durationMonths: dto.durationMonths,
            remainingMonths: dto.remainingMonths,
            
            accumulatedPenalty: Decimal(dto.accumulatedPenalty),
            overdueDays: dto.overdueDays,
            
            status: CreditStatus(rawValue: dto.status) ?? .active,
            
            issueDate: dto.issueDate,
            nextPaymentDate: dto.nextPaymentDate,

            createdAt: dto.createdAt,
            updatedAt: dto.updatedAt
        )
    }

    static func toDomain(_ dto: CreditPaymentDto) -> CreditPayment {
        CreditPayment(
            id: dto.id,
            creditId: dto.creditId,
            amount: Decimal(dto.amount),
            paymentType: CreditPaymentType(rawValue: dto.paymentType.rawValue) ?? .manualRepayment,
            paymentDate: dto.paymentDate,
            createdAt: dto.createdAt
        )
    }
    
    static func toDomain(_ dto: CreditRatingDto) -> CreditRating {
        CreditRating(
            score: dto.score,
            ratingLevel: dto.ratingLevel ?? "Unknown"
        )
    }

    static func toDomain(_ dto: CreditApplicationDto) -> CreditApplication {
        let status = CreditApplicationStatus(rawValue: dto.status ?? "") ?? .pending
        
        return CreditApplication(
            id: dto.id,
            tariffName: dto.tariffName ?? "Credit",
            amount: Decimal(dto.amount),
            status: status
        )
    }

    static func toDomain(_ dto: OverduePaymentDto) -> OverduePayment {
        OverduePayment(
            scheduleId: dto.scheduleId,
            creditId: dto.creditId,
            remainingDue: Decimal(dto.remainingDue),
            overdueDays: dto.overdueDays
        )
    }

    static func toDomain(_ dto: TakeCreditResultDto) -> TakeCreditResult {
        TakeCreditResult(
            message: dto.message,
            credit: dto.credit.map { toDomain($0) },
            application: dto.application.map { toDomain($0) }
        )
    }
}
