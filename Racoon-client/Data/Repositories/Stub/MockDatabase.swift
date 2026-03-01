//
//  MockDatabase.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import Foundation

public actor MockDatabase {
    public static let shared = MockDatabase()

    private var accounts: [UUID: BankAccountDto] = [:]
    private var operations: [UUID: [BankAccountOperationDto]] = [:]

    private var credits: [Int64: CreditDto] = [:]
    private var payments: [Int64: [CreditPaymentDto]] = [:]
    private var nextCreditId: Int64 = 1000

    private let userId = UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!

    private init() {
        let a1 = BankAccountDto(
            id: UUID(),
            userId: userId,
            accountNumber: "40817 0000 0000 0001",
            balance: 1250.0,
            createdAt: Date().addingTimeInterval(-86400 * 5)
        )
        let a2 = BankAccountDto(
            id: UUID(),
            userId: userId,
            accountNumber: "40817 0000 0000 0002",
            balance: 0.0,
            createdAt: Date().addingTimeInterval(-86400 * 2)
        )
        accounts[a1.id] = a1
        accounts[a2.id] = a2
        operations[a1.id] = []
        operations[a2.id] = []
    }
    private var tariffs: [Int64: CreditTariffDto] = [
        1: CreditTariffDto(
            id: 1,
            name: "Standard",
            interestRate: 12.5,
            dueDate: Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date(),
            isActive: true,
            createdAt: Date().addingTimeInterval(-86400 * 30)
        ),
        2: CreditTariffDto(
            id: 2,
            name: "Premium",
            interestRate: 9.9,
            dueDate: Calendar.current.date(byAdding: .day, value: 60, to: Date()) ?? Date(),
            isActive: true,
            createdAt: Date().addingTimeInterval(-86400 * 60)
        )
    ]

    // MARK: - Accounts

    public func getMyAccounts() -> [BankAccountDto] {
        accounts.values.sorted { $0.createdAt > $1.createdAt }
    }

    public func openAccount() -> BankAccountDto {
        let id = UUID()
        let dto = BankAccountDto(
            id: id,
            userId: userId,
            accountNumber: "40817 0000 0000 \(String(Int.random(in: 1000...9999)))",
            balance: 0.0,
            createdAt: Date()
        )
        accounts[id] = dto
        operations[id] = []
        return dto
    }

    public func closeAccount(id: UUID) throws {
        guard accounts[id] != nil else { throw NetworkError.httpStatus(code: 404, body: Data()) }
        accounts.removeValue(forKey: id)
        operations.removeValue(forKey: id)
    }

    public func deposit(id: UUID, amount: Double) throws -> BankAccountDto {
        guard amount > 0 else { throw NetworkError.httpStatus(code: 400, body: Data()) }
        guard var acc = accounts[id] else { throw NetworkError.httpStatus(code: 404, body: Data()) }

        acc = BankAccountDto(
            id: acc.id,
            userId: acc.userId,
            accountNumber: acc.accountNumber,
            balance: acc.balance + amount,
            createdAt: acc.createdAt
        )
        accounts[id] = acc

        let op = BankAccountOperationDto(
            id: UUID(),
            amount: amount,
            type: .deposit,
            createdAt: Date()
        )
        operations[id, default: []].insert(op, at: 0)

        return acc
    }

    public func withdraw(id: UUID, amount: Double) throws -> BankAccountDto {
        guard amount > 0 else { throw NetworkError.httpStatus(code: 400, body: Data()) }
        guard var acc = accounts[id] else { throw NetworkError.httpStatus(code: 404, body: Data()) }
        guard acc.balance >= amount else { throw NetworkError.httpStatus(code: 409, body: Data()) } // insufficient funds

        acc = BankAccountDto(
            id: acc.id,
            userId: acc.userId,
            accountNumber: acc.accountNumber,
            balance: acc.balance - amount,
            createdAt: acc.createdAt
        )
        accounts[id] = acc

        let op = BankAccountOperationDto(
            id: UUID(),
            amount: amount,
            type: .withdraw,
            createdAt: Date()
        )
        operations[id, default: []].insert(op, at: 0)

        return acc
    }
    public func history(id: UUID) throws -> [BankAccountOperationDto] {
        guard accounts[id] != nil else { throw NetworkError.httpStatus(code: 404, body: Data()) }
        return operations[id] ?? []
    }

    // MARK: - Credits

    public func getMyCredits() -> [CreditDto] {
        credits.values.sorted { $0.createdAt > $1.createdAt }
    }

    public func getTariffs() -> [CreditTariffDto] {
        tariffs.values.sorted { $0.id < $1.id }
    }

    public func getTariff(id: Int64) throws -> CreditTariffDto {
        guard let t = tariffs[id] else { throw NetworkError.httpStatus(code: 404, body: Data()) }
        return t
    }

    public func takeCredit(bankAccountId: String, tariffId: Int64, amount: Double, durationMonths: Int) throws -> CreditDto {
        guard amount > 0, durationMonths > 0 else { throw NetworkError.httpStatus(code: 400, body: Data()) }
        guard tariffs[tariffId] != nil else { throw NetworkError.httpStatus(code: 404, body: Data()) }

        nextCreditId += 1
        let id = nextCreditId

        let tariffName = tariffs[tariffId]?.name ?? "Tariff #\(tariffId)"
        let interestRate = tariffs[tariffId]?.interestRate ?? 12.5

        // Very simple financial model for mock:
        // total = amount * (1 + rate)
        // monthly = total / months
        let totalToPay = amount * (1.0 + interestRate / 100.0)
        let monthlyPayment = totalToPay / Double(durationMonths)

        let now = Date()
        let nextPay = Calendar.current.date(byAdding: .month, value: 1, to: now) ?? now.addingTimeInterval(86400 * 30)

        let dto = CreditDto(
            id: id,
            ownerId: userId.uuidString,
            tariffId: tariffId,
            tariffName: tariffName,
            interestRate: interestRate,
            amount: amount,
            remainingAmount: amount,
            monthlyPayment: monthlyPayment,
            durationMonths: durationMonths,
            remainingMonths: durationMonths,
            accumulatedPenalty: 0.0,
            overdueDays: 0,
            status: CreditStatus.active.rawValue,
            issueDate: now,
            nextPaymentDate: nextPay,
            createdAt: now,
            updatedAt: nil
        )

        credits[id] = dto
        payments[id] = []
        return dto
    }

    public func getCredit(id: Int64) throws -> CreditDto {
        guard let dto = credits[id] else { throw NetworkError.httpStatus(code: 404, body: Data()) }
        return dto
    }

    public func getPayments(creditId: Int64) throws -> [CreditPaymentDto] {
        guard credits[creditId] != nil else { throw NetworkError.httpStatus(code: 404, body: Data()) }
        return payments[creditId] ?? []
    }

    public func repayCredit(creditId: Int64, bankAccountId: String, amount: Double) throws -> CreditPaymentDto {
        guard amount > 0 else { throw NetworkError.httpStatus(code: 400, body: Data()) }
        guard var credit = credits[creditId] else { throw NetworkError.httpStatus(code: 404, body: Data()) }

        let newRemaining = max(0, credit.remainingAmount - amount)
        let newRemainingMonths = (newRemaining == 0) ? 0 : max(0, credit.remainingMonths - 1)
        let newStatus = (newRemaining == 0) ? CreditStatus.paidOff.rawValue : credit.status

        credit = CreditDto(
            id: credit.id,
            ownerId: credit.ownerId,
            tariffId: credit.tariffId,
            tariffName: credit.tariffName,
            interestRate: credit.interestRate,
            amount: credit.amount,
            remainingAmount: newRemaining,
            monthlyPayment: credit.monthlyPayment,
            durationMonths: credit.durationMonths,
            remainingMonths: newRemainingMonths,
            accumulatedPenalty: credit.accumulatedPenalty,
            overdueDays: credit.overdueDays,
            status: newStatus,
            issueDate: credit.issueDate,
            nextPaymentDate: Calendar.current.date(byAdding: .month, value: 1, to: credit.nextPaymentDate) ?? credit.nextPaymentDate,
            createdAt: credit.createdAt,
            updatedAt: Date()
        )

        credits[creditId] = credit

        let payment = CreditPaymentDto(
            id: Int64.random(in: 10_000...99_999),
            creditId: creditId,
            amount: amount,
            paymentType: .manualRepayment,
            paymentDate: Date(),
            createdAt: Date()
        )
        payments[creditId, default: []].insert(payment, at: 0)
        return payment
    }

    public func getStatistics(creditId: Int64) throws -> CreditStatisticsDto {
        guard let credit = credits[creditId] else {
            throw NetworkError.httpStatus(code: 404, body: Data())
        }

        // Basic totals (align to backend fields)
        let originalAmount = credit.amount
        let monthlyPayment = credit.monthlyPayment
        let durationMonths = credit.durationMonths
        let interestRate = credit.interestRate

        let totalToRepay = monthlyPayment * Double(durationMonths)
        let totalInterest = max(0, totalToRepay - originalAmount)

        return CreditStatisticsDto(
            creditId: creditId,
            originalAmount: originalAmount,
            monthlyPayment: monthlyPayment,
            durationMonths: durationMonths,
            interestRate: interestRate,
            totalToRepay: totalToRepay,
            totalInterest: totalInterest, totalPaid: nil
        )
    }

    public func getSchedule(creditId: Int64) throws -> [PaymentScheduleDto] {
        guard let credit = credits[creditId] else { throw NetworkError.httpStatus(code: 404, body: Data()) }

        let months = max(credit.remainingMonths, 0)
        guard months > 0 else { return [] }

        let amount = credit.monthlyPayment
        var result: [PaymentScheduleDto] = []
        let base = credit.nextPaymentDate

        var remaining = credit.remainingAmount
        let monthlyPayment = credit.monthlyPayment
        let interestRate = credit.interestRate

        for i in 0..<months {
            let paymentDate = Calendar.current.date(byAdding: .month, value: i, to: base) ?? base

            let interestPart = remaining * (interestRate / 100.0)
            let principalPart = max(0, monthlyPayment - interestPart)
            remaining = max(0, remaining - principalPart)

            result.append(
                PaymentScheduleDto(
                    id: Int64(1000 + i),
                    creditId: credit.id,
                    monthNumber: i + 1,
                    paymentDate: paymentDate,
                    totalPayment: monthlyPayment,
                    interestPayment: interestPart,
                    principalPayment: principalPart,
                    remainingBalance: remaining,
                    paid: false
                )
            )
        }
        return result
    }
}
