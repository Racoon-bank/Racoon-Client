//
//  AppRuntimeConfig.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//
import Foundation

public struct AppRuntimeConfig: Sendable {
    public let mode: AppRuntimeMode
    public let baseURL: URL

    public init(mode: AppRuntimeMode, baseURL: URL) {
        self.mode = mode
        self.baseURL = baseURL
    }

    public static func current() -> AppRuntimeConfig {
#if DEBUG
        
        return AppRuntimeConfig(mode: .mock, baseURL: URL(string: "http://localhost:8080")!)
#else
        return AppRuntimeConfig(mode: .live, baseURL: URL(string: "https://prodHost")!)
#endif
    }
}
