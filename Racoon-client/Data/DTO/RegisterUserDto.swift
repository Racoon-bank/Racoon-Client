//
//  RegisterUserDto.swift
//  Racoon-client
//
//  Created by dark type on 01.03.2026.
//


public struct RegisterUserDto: Encodable, Sendable {
    public let username: String
    public let email: String?
    public let password: String

    public init(username: String, email: String?, password: String) {
        self.username = username
        self.email = email
        self.password = password
    }
}
