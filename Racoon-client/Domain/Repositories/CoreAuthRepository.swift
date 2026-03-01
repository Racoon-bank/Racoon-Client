//
//  CoreAuthRepository.swift
//  Racoon-client
//
//  Created by dark type on 26.02.2026.
//


public protocol CoreAuthRepository: Sendable {
    func login(email: String, password: String) async throws -> AuthTokensDto
    func refresh(refreshToken: String) async throws -> AuthTokensDto
    func register(username: String, email: String?, password: String) async throws -> AuthTokensDto
    func logout(accessToken: String) async throws
}
