//
//  CoreRouter.swift
//  Racoon-client
//
//  Created by dark type on 26.02.2026.
//

import Foundation

public enum CoreRouter: APIRouter {
    case closeAccount(id: UUID)
    case myAccounts
    case deposit(id: UUID, amount: Double)
    case withdraw(id: UUID, amount: Double)
    case history(id: UUID)

    case login(email: String, password: String)
    case refresh(refreshToken: String)
    case logout
    case openAccount(currency: String)
       case changeVisibility(id: UUID)
       case transfer(fromAccountId: UUID, toAccountNumber: String?, amount: Double)

    public var endpoint: Endpoint {
        switch self {
        case .openAccount(let currency):
                    return Endpoint(
                        service: .core,
                        method: .POST,
                        path: "/api/bank-accounts",
                        body: .json(CreateBankAccountDto(currency: currency))
                    )
                    
                case .changeVisibility(let id):
                    return Endpoint(
                        service: .core,
                        method: .PUT,
                        path: "/api/bank-accounts/\(id.uuidString)"
                    )
                    
                case .transfer(let fromAccountId, let toAccountNumber, let amount):
                    return Endpoint(
                        service: .core,
                        method: .PUT,
                        path: "/api/bank-accounts/transfer",
                        body: .json(TransferDto(
                            fromAccountId: fromAccountId,
                            toAccountNumber: toAccountNumber,
                            amount: amount
                        ))
                    )
                

        case .closeAccount(let id):
            return Endpoint(service: .core,method: .DELETE, path: "/api/bank-accounts/\(id.uuidString)")

        case .myAccounts:
            return Endpoint(service: .core,method: .GET, path: "/api/bank-accounts/my")

        case .deposit(let id, let amount):
            return Endpoint(
                service: .core,
                method: .PUT,
                path: "/api/bank-accounts/\(id.uuidString)/deposit",
                body: .json(MoneyOperationDto(amount: amount))
            )

        case .withdraw(let id, let amount):
            return Endpoint(
                service: .core,
                method: .PUT,
                path: "/api/bank-accounts/\(id.uuidString)/withdraw",
                body: .json(MoneyOperationDto(amount: amount))
            )

        case .history(let id):
            return Endpoint(service: .core,method: .GET, path: "/api/bank-accounts/\(id.uuidString)/history")

        case .login(let email, let password):
            return Endpoint(
                service: .core,
                method: .POST,
                path: "/api/auth/login",
                body: .json(LoginRequestDto(email: email, password: password))
            )

        case .refresh(let refreshToken):
            return Endpoint(
                service: .core,
                method: .POST,
                path: "/api/auth/refresh",
                body: .json(RefreshRequestDto(refreshToken: refreshToken))
            )

        case .logout:
            return Endpoint(service: .core,method: .POST, path: "/api/auth/logout")
        }
    }
}





