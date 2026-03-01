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
}
