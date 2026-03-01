//
//  LoginUseCase.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import Foundation

public protocol LoginUseCase: Sendable {
    func callAsFunction(email: String, password: String) async throws -> AuthTokens
}

public struct LoginUseCaseImpl: LoginUseCase {
    private let authRepo: any CoreAuthRepository
    private let events: DomainEventBus

    public init(authRepo: any CoreAuthRepository, events: DomainEventBus) {
        self.authRepo = authRepo
        self.events = events
    }

    public func callAsFunction(email: String, password: String) async throws -> AuthTokens {
        let dto = try await authRepo.login(email: email, password: password)
        let tokens = AuthTokens(accessToken: dto.accessToken, refreshToken: dto.refreshToken)
        await events.publish(.authLoggedIn)
        return tokens
    }
}
