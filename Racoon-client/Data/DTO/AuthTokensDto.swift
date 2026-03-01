//
//  AuthTokensDto.swift
//  Racoon-client
//
//  Created by dark type on 26.02.2026.
//


public struct AuthTokensDto: Decodable, Sendable {
    public let accessToken: String
    public let refreshToken: String
}