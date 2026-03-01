//
//  RefreshRequestDto.swift
//  Racoon-client
//
//  Created by dark type on 26.02.2026.
//

import Foundation

public struct RefreshRequestDto: Encodable, Sendable {
    public let refreshToken: String
}
