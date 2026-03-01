//
//  LogoutUseCase.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import Foundation

public protocol LogoutUseCase: Sendable {
    func callAsFunction() async throws
}

public struct LogoutUseCaseImpl: LogoutUseCase {
    private let authRepo: any CoreAuthRepository
    private let tokenStore: TokenStore
    private let events: DomainEventBus

    public init(authRepo: any CoreAuthRepository, tokenStore: TokenStore, events: DomainEventBus) {
        self.authRepo = authRepo
        self.tokenStore = tokenStore
        self.events = events
    }

    public func callAsFunction() async throws {
        let tokens = await tokenStore.readTokens()

        do {
            if let access = tokens?.accessToken, !access.isEmpty {
                try await authRepo.logout(accessToken: access)
            } else {
            }
        } catch {
            await tokenStore.clearTokens()
            await events.publish(.authLoggedOut)
            return
        }

        await tokenStore.clearTokens()
        await events.publish(.authLoggedOut)
    }
}
