//
//  AppFallbackView.swift
//  Racoon-client
//
//  Created by dark type on 22.03.2026.
//

import SwiftUI

struct AppFallbackView: View {
    let title: String
    let message: String
    let canRetry: Bool
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 44))

            Text(title)
                .font(.title2)
                .bold()

            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            if canRetry {
                Button("Retry", action: onRetry)
                    .buttonStyle(.borderedProminent)
            }

            Spacer()
        }
        .padding(24)
    }
}
