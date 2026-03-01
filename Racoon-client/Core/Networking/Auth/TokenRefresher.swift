//
//  TokenRefresher.swift
//  Racoon-client
//
//  Created by dark type on 26.02.2026.
//


public protocol TokenRefresher: Sendable {
    func refreshTokens(current: AuthTokens) async throws -> AuthTokens
}