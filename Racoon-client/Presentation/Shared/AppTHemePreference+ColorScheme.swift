//
//  AppTHemePreference+ColorScheme.swift
//  Racoon-client
//
//  Created by dark type on 18.03.2026.
//

import SwiftUI

extension AppThemePreference {
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
