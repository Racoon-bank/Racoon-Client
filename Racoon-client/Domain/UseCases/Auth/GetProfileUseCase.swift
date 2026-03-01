//
//  GetProfileUseCase.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import Foundation

public protocol GetProfileUseCase: Sendable {
    func callAsFunction() async throws -> UserProfile
}

public struct GetProfileUseCaseImpl: GetProfileUseCase {
    private let infoRepo: InfoUserRepository

    public init(infoRepo: InfoUserRepository) {
        self.infoRepo = infoRepo
    }

    public func callAsFunction() async throws -> UserProfile {
        let dto = try await infoRepo.profile()
        return UserProfileMapper.toDomain(dto)
    }
}
