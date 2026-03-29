//
//  AppSettings.swift
//  Racoon-client
//
//  Created by dark type on 22.03.2026.
//

import Foundation

public struct AppSettings: Codable, Sendable, Equatable {
    public let theme: AppThemePreference
    public let hiddenAccountIds: Set<UUID>

    public init(
        theme: AppThemePreference = .system,
        hiddenAccountIds: Set<UUID> = []
    ) {
        self.theme = theme
        self.hiddenAccountIds = hiddenAccountIds
    }

    public func withTheme(_ theme: AppThemePreference) -> AppSettings {
        AppSettings(theme: theme, hiddenAccountIds: hiddenAccountIds)
    }

    public func withHiddenAccountIds(_ ids: Set<UUID>) -> AppSettings {
        AppSettings(theme: theme, hiddenAccountIds: ids)
    }

    public func togglingHidden(accountId: UUID) -> AppSettings {
        var ids = hiddenAccountIds
        if ids.contains(accountId) {
            ids.remove(accountId)
        } else {
            ids.insert(accountId)
        }
        return AppSettings(theme: theme, hiddenAccountIds: ids)
    }
}
