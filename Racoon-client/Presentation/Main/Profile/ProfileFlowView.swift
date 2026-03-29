//
//  ProfileFlowView.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import SwiftUI

struct ProfileFlowView: View {
    @Environment(\.appContainer) private var container
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            let factory = ViewModelFactory(container: container)
            ProfileView(viewModel: factory.makeProfileViewModel(appState: appState))
        }
    }
}
