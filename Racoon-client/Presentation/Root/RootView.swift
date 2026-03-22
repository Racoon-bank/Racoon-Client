//
//  RootView.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        Group {
            if let fallback = appState.fallbackError {
                AppFallbackView(
                    title: fallback.title,
                    message: fallback.message,
                    canRetry: fallback.canRetry,
                    onRetry: {
                        Task { await appState.retryBootstrap() }
                    }
                )
            } else {
                switch appState.session {
                case .unknown:
                    ProgressView()
                        .task { await appState.bootstrap() }

                case .unauthenticated:
                    AuthFlowView()

                case .authenticated:
                    MainFlowView()
                }
            }
        }
        .alert(
            appState.globalError?.title ?? "Error",
            isPresented: Binding(
                get: { appState.globalError != nil },
                set: { if !$0 { appState.clearGlobalError() } }
            )
        ) {
            Button("OK") {
                appState.clearGlobalError()
            }
        } message: {
            Text(appState.globalError?.message ?? "")
        }
    }
}
