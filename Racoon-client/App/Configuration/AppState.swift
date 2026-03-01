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
    enum SessionState: Equatable { case unknown, unauthenticated, authenticated }

    @Published private(set) var session: SessionState = .unknown

    @Published var lastCreatedCreditId: Int64?

    private let container: AppContainer

    init(container: AppContainer) {
        self.container = container
    }

    func bootstrap() async {
        let tokens = await container.tokenStore.readTokens()
        session = (tokens == nil) ? .unauthenticated : .authenticated
    }

    func onLoggedIn() { session = .authenticated }
    func onLoggedOut() {
        session = .unauthenticated
        lastCreatedCreditId = nil
    }
}
