//
//  CoreAuthRepositoryMock.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import Foundation

public final class CoreAuthRepositoryMock: CoreAuthRepository, TokenRefresher {
    private let tokenStore: TokenStore

    public init(tokenStore: TokenStore) {
        self.tokenStore = tokenStore
    }

    public func login(email: String, password: String) async throws -> AuthTokensDto {
        let dto = AuthTokensDto(accessToken: "mock_access", refreshToken: "mock_refresh")
        await tokenStore.saveTokens(.init(accessToken: dto.accessToken, refreshToken: dto.refreshToken))
        return dto
    }

    public func refresh(refreshToken: String) async throws -> AuthTokensDto {
        let dto = AuthTokensDto(accessToken: "mock_access_refreshed", refreshToken: "mock_refresh_refreshed")
        await tokenStore.saveTokens(.init(accessToken: dto.accessToken, refreshToken: dto.refreshToken))
        return dto
    }

    public func register(username: String, email: String?, password: String) async throws -> AuthTokensDto {
        // in mock, behaves like login
        let dto = AuthTokensDto(accessToken: "mock_access_registered", refreshToken: "mock_refresh_registered")
        await tokenStore.saveTokens(.init(accessToken: dto.accessToken, refreshToken: dto.refreshToken))
        return dto
    }

    public func refreshTokens(current: AuthTokens) async throws -> AuthTokens {
        let dto = try await refresh(refreshToken: current.refreshToken)
        return AuthTokens(accessToken: dto.accessToken, refreshToken: dto.refreshToken)
    }

    public func logout(accessToken: String) async throws {
        // token is ignored in mock
        await tokenStore.clearTokens()
    }
}
