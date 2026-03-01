//
//  InfoUserRepository.swift
//  Racoon-client
//
//  Created by dark type on 26.02.2026.
//


public protocol InfoUserRepository: Sendable {
    func profile() async throws -> UserProfileDto
}