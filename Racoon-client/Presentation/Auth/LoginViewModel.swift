//
//  LoginViewModel.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import Combine
import Foundation
import AuthenticationServices

@MainActor
final class LoginViewModel: ObservableObject {
    @Published private(set) var state: AsyncViewState = .idle

    private let completeLogin: CompleteSSOLoginUseCase
    private let ssoManager = SSOAuthManager()
    private unowned let appState: AppState

    init(completeLogin: CompleteSSOLoginUseCase, appState: AppState) {
        self.completeLogin = completeLogin
        self.appState = appState
    }

    func submit() async {
        guard !state.isLoading else { return }
        state = .loading

        do {
            let tokens = try await ssoManager.login()
        
            try await completeLogin(tokens: tokens)
            
            state = .success
            appState.onLoggedIn()
        } catch let error as ASWebAuthenticationSessionError where error.code == .canceledLogin {
            state = .idle
        } catch {
            state = .error(message: "SSO Login failed. Please try again.")
        }
    }

    func clearError() {
        if case .error = state { state = .idle }
    }
}

// MARK: - SSO Manager
@MainActor
final class SSOAuthManager: NSObject, ASWebAuthenticationPresentationContextProviding {
    private var authSession: ASWebAuthenticationSession?

    func login() async throws -> AuthTokens {
        return try await withCheckedThrowingContinuation { continuation in
            let redirectURI = "myapp://callback"
            let backendLoginURL = "https://info.hits-playground.ru/api/auth/login?redirectUrl=\(redirectURI)"
            
            guard let url = URL(string: backendLoginURL) else {
                print("❌ SSO: Invalid backend URL")
                continuation.resume(throwing: URLError(.badURL))
                return
            }

            print("🌐 SSO: Opening browser with URL: \(url)")

            authSession = ASWebAuthenticationSession(url: url, callbackURLScheme: "myapp") { callbackURL, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let callbackURL = callbackURL else {
                    print("❌ SSO: No callback URL received.")
                    continuation.resume(throwing: URLError(.badServerResponse))
                    return
                }

                print("✅ SSO: Intercepted Redirect URL:\n\(callbackURL.absoluteString)")

                guard let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false) else {
                    print("❌ SSO: Could not parse URL components.")
                    continuation.resume(throwing: URLError(.badServerResponse))
                    return
                }
                
                print("🔍 SSO: Query Parameters found: \(components.queryItems?.map { "\($0.name)=\($0.value ?? "nil")" } ?? [])")

                guard let queryItems = components.queryItems,
                      let accessToken = queryItems.first(where: { $0.name == "access_token" })?.value,
                      let refreshToken = queryItems.first(where: { $0.name == "refresh_token" })?.value else {
                    
                    print("❌ SSO: Failed to find access_token or refresh_token in the URL queries!")
                    continuation.resume(throwing: URLError(.badServerResponse))
                    return
                }

                print("🎉 SSO: Successfully extracted tokens!")
                print("   -> Access Token (first 10 chars): \(accessToken.prefix(10))...")
                print("   -> Refresh Token (first 10 chars): \(refreshToken.prefix(10))...")

                continuation.resume(returning: AuthTokens(accessToken: accessToken, refreshToken: refreshToken))
            }

            authSession?.presentationContextProvider = self
            authSession?.start()
        }
    }
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }
}
