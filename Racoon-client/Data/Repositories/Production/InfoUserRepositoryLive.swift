//
//  InfoUserRepositoryLive.swift
//  Racoon-client
//
//  Created by dark type on 26.02.2026.
//



public final class InfoUserRepositoryLive: InfoUserRepository {
    private let client: HTTPClient
    public init(client: HTTPClient) { self.client = client }

    public func profile() async throws -> UserProfileDto {
        try await client.send(InfoRouter.profile, as: UserProfileDto.self)
    }
    public func switchTheme() async throws {
           try await client.sendNoResponse(InfoRouter.switchTheme)
       }
}
