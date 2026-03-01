//
//  UserProfileMapper.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//

import Foundation

enum UserProfileMapper {
    static func toDomain(_ dto: UserProfileDto) -> UserProfile {
        UserProfile(
            id: UUID(uuidString: dto.id) ?? UUID(),
            username: dto.username,
            email: dto.email
        )
    }
}
