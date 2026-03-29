//
//  AppRepositoryLive.swift
//  Racoon-client
//
//  Created by dark type on 30.03.2026.
//

import Foundation

public final class AppRepositoryLive: AppRepository {
    private let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public func getAppInfo() async throws -> AppInfoDto {
        try await client.send(InfoRouter.appInfo, as: AppInfoDto.self)
    }
    
    public func switchTheme() async throws {
        try await client.sendNoResponse(InfoRouter.switchAppTheme)
    }
    
    public func hideBankAccount(id: UUID) async throws {
        try await client.sendNoResponse(InfoRouter.hideBankAccount(id: id))
    }
    
    public func revealBankAccount(id: UUID) async throws {
        try await client.sendNoResponse(InfoRouter.revealBankAccount(id: id))
    }
}
