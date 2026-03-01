//
//  AuthMapper.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


enum AuthMapper {
    static func toDomain(_ dto: AuthTokensDto) -> AuthTokens {
        AuthTokens(accessToken: dto.accessToken, refreshToken: dto.refreshToken)
    }
}