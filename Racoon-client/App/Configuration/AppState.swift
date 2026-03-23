//
//  AppState.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import SwiftUI
import Combine

@MainActor
final class AppState: ObservableObject {
    enum SessionState: Equatable {
        case unknown
        case unauthenticated
        case authenticated
    }

    @Published private(set) var session: SessionState = .unknown
    @Published var lastCreatedCreditId: Int64?
    @Published var globalError: AppErrorState?
    @Published var fallbackError: AppErrorState?

    private let container: AppContainer

    init(container: AppContainer) {
        self.container = container

        Task {
            let stream = container.appErrorBus.stream()
            for await error in stream {
                await MainActor.run {
                    self.handleAppError(error)
                }
            }
        }
    }

    func onLoggedIn() {
        session = .authenticated
        Task { await container.bankHubClient.connect() }
    }

    func onLoggedOut() {
        session = .unauthenticated
        lastCreatedCreditId = nil
        fallbackError = nil
        Task { await container.bankHubClient.disconnect() }
    }

    func bootstrap() async {
        let tokens = await container.tokenStore.readTokens()
        session = (tokens == nil) ? .unauthenticated : .authenticated
    }

    func retryBootstrap() async {
        globalError = nil
        fallbackError = nil
        session = .unknown
        await container.bankHubClient.disconnect()
        await bootstrap()
    }

    private func handleAppError(_ error: AppErrorState) {
        switch error.kind {
        case .banner, .alert:
            globalError = error

        case .fallback:
            fallbackError = error

        case .forceLogout:
            onLoggedOut()
            globalError = AppErrorState(
                title: error.title,
                message: error.message,
                kind: .alert
            )
        }
    }

    func clearGlobalError() {
        globalError = nil
    }
}
