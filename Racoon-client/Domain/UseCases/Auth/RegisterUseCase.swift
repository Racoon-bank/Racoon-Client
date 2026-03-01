//
//  RegisterUseCase.swift
//  Racoon-client
//
//  Created by dark type on 01.03.2026.
//


public protocol RegisterUseCase: Sendable {
    func callAsFunction(username: String, email: String?, password: String) async throws -> AuthTokens
}

public struct RegisterUseCaseImpl: RegisterUseCase {
    private let authRepo: any CoreAuthRepository
    private let events: DomainEventBus

    public init(authRepo: any CoreAuthRepository, events: DomainEventBus) {
        self.authRepo = authRepo
        self.events = events
    }

    public func callAsFunction(username: String, email: String?, password: String) async throws -> AuthTokens {
        let dto = try await authRepo.register(username: username, email: email, password: password)
        let tokens = AuthTokens(accessToken: dto.accessToken, refreshToken: dto.refreshToken)
        await events.publish(.userRegistered) 
        return tokens
    }
}
