//
//  RepositoriesAssembly.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


public struct RepositoriesAssembly: Sendable {
    private let networking: NetworkingAssembly

    public init(networking: NetworkingAssembly) {
        self.networking = networking
    }

    public func makeCoreAuthRepository(
        bareClient: HTTPClient,
        tokenStore: TokenStore
    ) -> CoreAuthRepositoryLive {
        CoreAuthRepositoryLive(bareClient: bareClient, tokenStore: tokenStore)
    }

    public func makeCoreBankAccountRepository(authedClient: HTTPClient) -> CoreBankAccountRepository {
        CoreBankAccountRepositoryLive(client: authedClient)
    }

    public func makeInfoUserRepository(authedClient: HTTPClient) -> InfoUserRepository {
        InfoUserRepositoryLive(client: authedClient)
    }

    public func makeCreditRepository(authedClient: HTTPClient) -> CreditRepository {
        CreditRepositoryLive(client: authedClient)
    }
}
