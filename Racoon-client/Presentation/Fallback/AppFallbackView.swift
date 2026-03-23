//
//  AppFallbackView.swift
//  Racoon-client
//
//  Created by dark type on 22.03.2026.
//

import SwiftUI

struct AppFallbackView: View {
    @EnvironmentObject private var appState: AppState

    let title: String
    let message: String
    let canRetry: Bool
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.orange)

            Text(title)
                .font(.title2)
                .bold()

            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            VStack(spacing: 12) {
                if canRetry {
                    Button("Try again") {
                        onRetry()
                    }
                    .buttonStyle(.borderedProminent)
                }

                Button("Log out") {
                    appState.onLoggedOut()
                }
                .buttonStyle(.bordered)
            }

            Spacer()
        }
        .padding(24)
    }
}
