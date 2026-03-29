//
//  CreditRouter.swift
//  Racoon-client
//
//  Created by dark type on 26.02.2026.
//

import Foundation

public enum CreditRouter: APIRouter {
    case getMyCredits
    case getMyCreditRating
    case getMyApplications
    case getMyOverduePayments
    
    case take(bankAccountId: String, tariffId: Int64, amount: Double, durationMonths: Int)
    case get(creditId: Int64)
    case repay(creditId: Int64, bankAccountId: String, amount: Double)
    case payments(creditId: Int64)
    case statistics(creditId: Int64)
    case schedule(creditId: Int64)

    case tariffs
    case tariff(id: Int64)

    public var endpoint: Endpoint {
        switch self {
        case .getMyCredits:
            return Endpoint(service: .credit, method: .GET, path: "/api/credits/my")
        case .getMyCreditRating:
            return Endpoint(service: .credit, method: .GET, path: "/api/credits/my/rating")
        case .getMyApplications:
            return Endpoint(service: .credit, method: .GET, path: "/api/credits/my/applications")
        case .getMyOverduePayments:
            return Endpoint(service: .credit, method: .GET, path: "/api/credits/my/overdue-payments")

        case .take(let bankAccountId, let tariffId, let amount, let durationMonths):
            return Endpoint(
                service: .credit,
                method: .POST,
                path: "/api/credits",
                body: .json(
                    TakeCreditRequestDto(
                        bankAccountId: bankAccountId,
                        tariffId: tariffId,
                        amount: amount,
                        durationMonths: durationMonths
                    )
                )
            )

        case .get(let creditId):
            return Endpoint(service: .credit, method: .GET, path: "/api/credits/\(creditId)")

        case .repay(let creditId, let bankAccountId, let amount):
            return Endpoint(
                service: .credit,
                method: .POST,
                path: "/api/credits/\(creditId)/repay",
                body: .json(RepayCreditRequestDto(bankAccountId: bankAccountId, amount: amount))
            )

        case .payments(let creditId):
            return Endpoint(service: .credit, method: .GET, path: "/api/credits/\(creditId)/payments")

        case .statistics(let creditId):
            return Endpoint(service: .credit, method: .GET, path: "/api/credits/\(creditId)/statistics")

        case .schedule(let creditId):
            return Endpoint(service: .credit, method: .GET, path: "/api/credits/\(creditId)/schedule")

        case .tariffs:
            return Endpoint(service: .credit, method: .GET, path: "/api/tariffs")

        case .tariff(let id):
            return Endpoint(service: .credit, method: .GET, path: "/api/tariffs/\(id)")
        }
    }
}
