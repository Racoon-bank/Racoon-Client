//
//  AppSettingsStorage.swift
//  Racoon-client
//
//  Created by dark type on 22.03.2026.
//


public protocol AppSettingsStorage: Sendable {
    func load() -> AppSettings
    func save(_ settings: AppSettings)
}