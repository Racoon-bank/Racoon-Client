//
//  AppThemePreference.swift
//  Racoon-client
//
//  Created by dark type on 22.03.2026.
//


public enum AppThemePreference: String, Codable, Sendable, Equatable {
    case system
    case light
    case dark
}
extension AppThemePreference {
    init(profileTheme: Theme?) {
        switch profileTheme {
        case .Light:
            self = .light
        case .Dark:
            self = .dark
        case nil:
            self = .system
        }
    }
}
