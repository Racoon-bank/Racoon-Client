//
//  LoginViewModel.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import Combine
import Foundation

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""

    @Published private(set) var state: AsyncViewState = .idle

    private let login: LoginUseCase
    private unowned let appState: AppState

    init(login: LoginUseCase, appState: AppState) {
        self.login = login
        self.appState = appState
    }

    var canSubmit: Bool {
        isValidEmail(email) && password.count >= 4 && !state.isLoading
    }

    func submit() async {
        guard canSubmit else { return }
        state = .loading

        do {
            _ = try await login(
                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                password: password
            )
            state = .success
            appState.onLoggedIn()
        } catch {
            state = .error(message: "Login failed. Please check your credentials and try again.")
        }
    }

    func clearError() {
        if case .error = state { state = .idle }
    }
}

private extension LoginViewModel {
    func isValidEmail(_ s: String) -> Bool {
        let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.contains("@") && trimmed.contains(".") && trimmed.count >= 5
    }
}
