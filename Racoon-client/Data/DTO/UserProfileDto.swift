//
//  UserProfileDto.swift
//  Racoon-client
//
//  Created by dark type on 26.02.2026.
//


public struct UserProfileDto: Decodable, Sendable {
    public let id: String
    public let username: String
    public let email: String
}
