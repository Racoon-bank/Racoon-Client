//
//  CompleteSSOLoginUseCase.swift
//  Racoon-client
//
//  Created by dark type on 18.03.2026.
//


public protocol CompleteSSOLoginUseCase: Sendable {
    func callAsFunction(tokens: AuthTokens) async throws
}

public struct CompleteSSOLoginUseCaseImpl: CompleteSSOLoginUseCase {
    private let tokenStore: TokenStore
    private let events: DomainEventBus

    public init(tokenStore: TokenStore, events: DomainEventBus) {
        self.tokenStore = tokenStore
        self.events = events
    }

    public func callAsFunction(tokens: AuthTokens) async throws {
        
        await tokenStore.clearTokens()
        
        await tokenStore.saveTokens(tokens)
        
        await events.publish(.authLoggedIn)
    }
}
