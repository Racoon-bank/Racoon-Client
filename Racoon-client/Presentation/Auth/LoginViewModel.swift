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
        } catch let error as NetworkError {
            state = .error(message: mapLoginError(error))
        } catch {
            state = .error(message: "Login failed. Please try again.")
        }
    }

    func clearError() {
        if case .error = state { state = .idle }
    }

    private func isValidEmail(_ s: String) -> Bool {
        let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.contains("@") && trimmed.contains(".") && trimmed.count >= 5
    }

    private func mapLoginError(_ error: NetworkError) -> String {
        switch error {
        case .unauthorized:
            return "Incorrect email or password."
        case .transport(let urlError):
            switch urlError.code {
            case .notConnectedToInternet:
                return "No internet connection."
            case .timedOut:
                return "Request timed out. Please try again."
            default:
                return "Network error. Please try again."
            }
        case .httpStatus(let code, _):
            if 500...599 ~= code {
                return "Service is temporarily unavailable."
            }
            return "Login failed. Please try again."
        default:
            return "Login failed. Please try again."
        }
    }
}
