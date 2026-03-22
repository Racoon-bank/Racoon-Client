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
            id: dto.id,
            username: dto.username ?? "",
            email: dto.email ?? "",
            theme: dto.theme ?? .Light
        )
    }
}
