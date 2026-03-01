//
//  AuthTokens.swift
//  Racoon-client
//
//  Created by dark type on 26.02.2026.
//

public struct AuthTokens: nonisolated Codable, Equatable, Sendable {
    public let accessToken: String
    public let refreshToken: String
}
