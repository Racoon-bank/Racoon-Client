//
//  ConnectBankHubUseCase.swift
//  Racoon-client
//
//  Created by dark type on 18.03.2026.
//

import Foundation

public protocol ConnectBankHubUseCase: Sendable {
    func callAsFunction() async
}

public protocol DisconnectBankHubUseCase: Sendable {
    func callAsFunction()
}

public protocol SubscribeToAccountUseCase: Sendable {
    func callAsFunction(accountId: UUID) async throws
}

public protocol UnsubscribeFromAccountUseCase: Sendable {
    func callAsFunction(accountId: UUID) async throws
}



public struct ConnectBankHubUseCaseImpl: ConnectBankHubUseCase {
    private let client: BankHubClient
    public init(client: BankHubClient) { self.client = client }
    
    public func callAsFunction() async {
        await client.connect()
    }
}

public struct DisconnectBankHubUseCaseImpl: DisconnectBankHubUseCase {
    private let client: BankHubClient
    public init(client: BankHubClient) { self.client = client }
    
    public func callAsFunction() {
        Task { await client.disconnect() }
    }
}

public struct SubscribeToAccountUseCaseImpl: SubscribeToAccountUseCase {
    private let client: BankHubClient
    public init(client: BankHubClient) { self.client = client }
    
    public func callAsFunction(accountId: UUID) async throws {
        try await client.subscribeToAccount(accountId: accountId)
    }
}

public struct UnsubscribeFromAccountUseCaseImpl: UnsubscribeFromAccountUseCase {
    private let client: BankHubClient
    public init(client: BankHubClient) { self.client = client }
    
    public func callAsFunction(accountId: UUID) async throws {
        try await client.unsubscribeFromAccount(accountId: accountId)
    }
}
