//
//  RefreshCoordinator.swift
//  Racoon-client
//
//  Created by dark type on 26.02.2026.
//


public actor RefreshCoordinator {
    private var currentTask: Task<AuthTokens, Error>?

    public init() {}

    public func refreshIfNeeded(
        tokens: AuthTokens,
        refresher: TokenRefresher
    ) async throws -> AuthTokens {
        if let task = currentTask {
            return try await task.value
        }

        let task = Task { try await refresher.refreshTokens(current: tokens) }
        currentTask = task
        defer { currentTask = nil }
        return try await task.value
    }
}