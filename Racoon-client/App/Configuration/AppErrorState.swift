//
//  AppErrorState.swift
//  Racoon-client
//
//  Created by dark type on 22.03.2026.
//

import Foundation

public struct AppErrorState: Identifiable, Equatable, Sendable {
    public let id = UUID()
    public let title: String
    public let message: String
    public let kind: Kind
    public let canRetry: Bool

    public enum Kind: Equatable, Sendable {
        case banner
        case alert
        case fallback
        case forceLogout
    }

    public init(
        title: String,
        message: String,
        kind: Kind,
        canRetry: Bool = false
    ) {
        self.title = title
        self.message = message
        self.kind = kind
        self.canRetry = canRetry
    }
}
