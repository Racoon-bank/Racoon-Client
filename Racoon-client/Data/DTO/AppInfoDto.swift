//
//  AppInfoDto.swift
//  Racoon-client
//
//  Created by dark type on 30.03.2026.
//

import Foundation

public struct AppInfoDto: Decodable, Sendable {
    public let theme: String?
    public let hiddenBankAccounts: [UUID]?
}
