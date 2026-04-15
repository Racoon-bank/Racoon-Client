//
//  AuthInterceptor.swift
//  Racoon-client
//
//  Created by dark type on 26.02.2026.
//

import Foundation

public final class AuthInterceptor: HTTPInterceptor {
    private let tokenStore: TokenStore
    private let refresher: TokenRefresher
    private let coordinator: RefreshCoordinator
    private let appErrorBus: AppErrorBus
    
    public init(
        tokenStore: TokenStore,
        refresher: TokenRefresher,
        appErrorBus: AppErrorBus,
        coordinator: RefreshCoordinator = RefreshCoordinator()
    ) {
        self.tokenStore = tokenStore
        self.refresher = refresher
        self.appErrorBus = appErrorBus
        self.coordinator = coordinator
    }
    
    public func adapt(_ request: URLRequest) async throws -> URLRequest {
        guard let tokens = await tokenStore.readTokens() else {
            print("❌ AuthInterceptor: No tokens found in TokenStore! Sending request naked.")
            return request
        }
        
        var req = request
        req.setValue("Bearer \(tokens.accessToken)", forHTTPHeaderField: "Authorization")
        
        print("✅ AuthInterceptor: Successfully attached Bearer token to \(request.url?.path ?? "unknown path")")
        return req
    }
    
    public func retry(
        _ request: URLRequest,
        dueTo error: NetworkError,
        using client: HTTPClient
    ) async -> URLRequest? {
        guard case .unauthorized = error else { return nil }
        
        print("⚠️ AuthInterceptor: 401 Received for \(request.url?.path ?? ""). Attempting token refresh...")
        
        guard let tokens = await tokenStore.readTokens() else { return nil }
        
        do {
            let newTokens = try await coordinator.refreshIfNeeded(tokens: tokens, refresher: refresher)
            
            await tokenStore.clearTokens()
            await tokenStore.saveTokens(newTokens)
            
            var retried = request
            retried.setValue("Bearer \(newTokens.accessToken)", forHTTPHeaderField: "Authorization")
            print("✅ AuthInterceptor: Refresh successful! Retrying request.")
            return retried
        } catch {
            print("❌ AuthInterceptor: Refresh completely failed. Logging user out.")
            await tokenStore.clearTokens()
            
            appErrorBus.post(
                AppErrorState(
                    title: "Session expired",
                    message: "Please sign in again.",
                    kind: .forceLogout
                )
            )
            
            return nil
        }
    }
}
