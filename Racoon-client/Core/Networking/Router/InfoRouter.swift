//
//  InfoRouter.swift
//  Racoon-client
//
//  Created by dark type on 26.02.2026.
//

import Foundation

public enum InfoRouter: APIRouter {
    case profile
    case register(username: String, email: String?, password: String)
    case login(email: String, password: String)
    case refresh(refreshToken: String)
    case getSsoLoginPage(redirectUrl: String)
    case logout(accessToken: String)
    
    case appInfo
    case switchAppTheme
    case hideBankAccount(id: UUID)
    case revealBankAccount(id: UUID)

    public var endpoint: Endpoint {
        switch self {
        case .profile:
            return Endpoint(service: .info, method: .GET, path: "/api/user/profile")

        case .register(let username, let email, let password):
            return Endpoint(
                service: .info,
                method: .POST,
                path: "/api/user/registration",
                body: .json(RegisterUserDto(username: username, email: email, password: password))
            )

        case .login(let email, let password):
            return Endpoint(
                service: .info,
                method: .POST,
                path: "/api/auth/login",
                body: .json(LoginRequestDto(email: email, password: password))
            )

        case .refresh(let refreshToken):
            return Endpoint(
                service: .info,
                method: .POST,
                path: "/api/auth/refresh",
                body: .json(RefreshRequestDto(refreshToken: refreshToken))
            )

        case .logout(let accessToken):
            return Endpoint(
                service: .info,
                method: .POST,
                path: "/api/auth/logout",
                headers: ["Authorization": "Bearer \(accessToken)"]
            )
        
        case .getSsoLoginPage(let redirectUrl):
            return Endpoint(
                service: .info,
                method: .GET,
                path: "/api/auth/login?redirectUrl=\(redirectUrl)"
            )
            
        case .appInfo:
            return Endpoint(service: .info, method: .GET, path: "/app/info")
            
        case .switchAppTheme:
            return Endpoint(service: .info, method: .PUT, path: "/app/theme")
            
        case .hideBankAccount(let id):
            return Endpoint(service: .info, method: .POST, path: "/app/bankAccount/\(id.uuidString.lowercased())")
            
        case .revealBankAccount(let id):
            return Endpoint(service: .info, method: .DELETE, path: "/app/bankAccount/\(id.uuidString.lowercased())")
        }
    }
}
