//
//  LoginRequestDto.swift
//  Racoon-client
//
//  Created by dark type on 26.02.2026.
//

import Foundation

public struct LoginRequestDto: Encodable, Sendable {
    public let email: String
    public let password: String
}
