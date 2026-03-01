//
//  CoreAuthRepositoryLive.swift
//  Racoon-client
//
//  Created by dark type on 26.02.2026.
//

import Foundation

public final class CoreAuthRepositoryLive: CoreAuthRepository, TokenRefresher {
    private let bareClient: HTTPClient
    private let tokenStore: TokenStore

    public init(bareClient: HTTPClient, tokenStore: TokenStore) {
        self.bareClient = bareClient
        self.tokenStore = tokenStore
    }

    public func login(email: String, password: String) async throws -> AuthTokensDto {
        let dto = try await bareClient.send(
            InfoRouter.login(email: email, password: password),
            as: AuthTokensDto.self
        )
        await tokenStore.saveTokens(.init(accessToken: dto.accessToken, refreshToken: dto.refreshToken))
        return dto
    }

    public func refresh(refreshToken: String) async throws -> AuthTokensDto {
        let dto = try await bareClient.send(
            InfoRouter.refresh(refreshToken: refreshToken),
            as: AuthTokensDto.self
        )
        await tokenStore.saveTokens(.init(accessToken: dto.accessToken, refreshToken: dto.refreshToken))
        return dto
    }

    public func register(username: String, email: String?, password: String) async throws -> AuthTokensDto {
        let dto = try await bareClient.send(
            InfoRouter.register(username: username, email: email, password: password),
            as: AuthTokensDto.self
        )
        await tokenStore.saveTokens(.init(accessToken: dto.accessToken, refreshToken: dto.refreshToken))
        return dto
    }

    public func refreshTokens(current: AuthTokens) async throws -> AuthTokens {
        let dto = try await refresh(refreshToken: current.refreshToken)
        return AuthTokens(accessToken: dto.accessToken, refreshToken: dto.refreshToken)
    }

    public func logout(accessToken: String) async throws {
        // ✅ token in header, no body
        try await bareClient.sendNoResponse(InfoRouter.logout(accessToken: accessToken))

        // Always clear locally after request succeeds
        await tokenStore.clearTokens()
    }
}
