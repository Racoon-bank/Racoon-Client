//
//  CreditsFlowView.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import SwiftUI

struct CreditsFlowView: View {
    @Environment(\.appContainer) private var container
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            let factory = ViewModelFactory(container: container)
            CreditsHomeView(viewModel: factory.makeCreditsHomeViewModel(appState: appState))
        }
    }
}
