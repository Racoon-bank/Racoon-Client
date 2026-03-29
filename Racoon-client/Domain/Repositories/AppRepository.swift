//
//  AppRepository.swift
//  Racoon-client
//
//  Created by dark type on 30.03.2026.
//

import Foundation

public protocol AppRepository: Sendable {
    func getAppInfo() async throws -> AppInfoDto
    func switchTheme() async throws
    func hideBankAccount(id: UUID) async throws
    func revealBankAccount(id: UUID) async throws
}
