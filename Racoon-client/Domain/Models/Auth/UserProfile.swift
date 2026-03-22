//
//  UserProfile.swift
//  Racoon-client
//
//  Created by dark type on 26.02.2026.
//

import Foundation

public struct UserProfile: Sendable, Equatable {
    public let id: UUID
    public let username: String
    public let email: String
    public let theme: Theme
}
