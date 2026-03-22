//
//  LoadAppSettingsUseCase.swift
//  Racoon-client
//
//  Created by dark type on 22.03.2026.
//


public protocol LoadAppSettingsUseCase: Sendable {
    func callAsFunction() async throws -> AppSettings
}
public struct LoadAppSettingsUseCaseMock: LoadAppSettingsUseCase {
    public init() {}

    public func callAsFunction() async throws -> AppSettings {
        AppSettings(theme: .system, hiddenAccountIds: [])
    }
}
