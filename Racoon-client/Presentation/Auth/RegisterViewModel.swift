//
//  RegisterViewModel.swift
//  Racoon-client
//
//  Created by dark type on 01.03.2026.
//


import SwiftUI
import Combine

@MainActor
final class RegisterViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var password: String = ""

    @Published private(set) var state: AsyncViewState = .idle

    private let register: RegisterUseCase
    private unowned let appState: AppState

    init(register: RegisterUseCase, appState: AppState) {
        self.register = register
        self.appState = appState
    }

    var canSubmit: Bool {
        isValidUsername(username) && isValidPassword(password) && isValidOptionalEmail(email) && !state.isLoading
    }

    func submit() async {
        guard canSubmit else { return }
        state = .loading

        do {
            _ = try await register(
                username: username.trimmingCharacters(in: .whitespacesAndNewlines),
                email: normalizedEmailOrNil(email),
                password: password
            )
            state = .success
            appState.onLoggedIn()
        } catch {
            state = .error(message: "Registration failed. Please try again.")
        }
    }

    func clearError() {
        if case .error = state { state = .idle }
    }
}

private extension RegisterViewModel {
    func isValidUsername(_ s: String) -> Bool {
        let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
        return t.count >= 3
    }

    func isValidPassword(_ s: String) -> Bool {
        s.count >= 4
    }

    func isValidOptionalEmail(_ s: String) -> Bool {
        let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.isEmpty { return true }
        return t.contains("@") && t.contains(".") && t.count >= 5
    }

    func normalizedEmailOrNil(_ s: String) -> String? {
        let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
        return t.isEmpty ? nil : t
    }
}
